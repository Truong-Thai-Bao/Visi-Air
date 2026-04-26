import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2' 

from flask import Flask, request, jsonify
# from flask_cors import CORS
import joblib
import numpy as np
import pandas as pd
import requests
from datetime import datetime, timedelta
import os
os.environ["CUDA_VISIBLE_DEVICES"] = "-1" #ko tìm GPU
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2' #tắt log
import tensorflow as tf

app = Flask(__name__)
# CORS(app) # Mở khóa bảo mật CORS cho Frontend

# ==========================================
# 1. LOAD MÔ HÌNH VÀ SCALER (7 FEATURES, 24 TIMESTEPS)
# ==========================================
print("⏳ Đang tải mô hình và hệ thống Scaler...")

try:
    model = tf.keras.models.load_model('pm25_cnn_bilstm_attention.h5', compile=False)
    scaler_X = joblib.load('scaler_X.pkl')
    scaler_y = joblib.load('scaler_y.pkl')
    print("✅ Tải mô hình thành công, sẵn sàng nhận Request!")
except Exception as e:
    print(f"❌ Lỗi khởi tạo mô hình: {e}")

# ==========================================
# 2. CÁC HÀM TÍNH AQI
# ==========================================
def calc_aqi(pm25):
    if pm25 < 0: return 0
    if pm25 <= 12.0: return round(((50 - 0) / (12.0 - 0)) * (pm25 - 0) + 0)
    elif pm25 <= 35.4: return round(((100 - 51) / (35.4 - 12.1)) * (pm25 - 12.1) + 51)
    elif pm25 <= 55.4: return round(((150 - 101) / (55.4 - 35.5)) * (pm25 - 35.5) + 101)
    elif pm25 <= 150.4: return round(((200 - 151) / (150.4 - 55.5)) * (pm25 - 55.5) + 151)
    elif pm25 <= 250.4: return round(((300 - 201) / (250.4 - 150.5)) * (pm25 - 150.5) + 201)
    elif pm25 <= 350.4: return round(((400 - 301) / (350.4 - 250.5)) * (pm25 - 250.5) + 301)
    else: return round(((500 - 401) / (500.4 - 350.5)) * (pm25 - 350.5) + 401)

def get_aqi_status(aqi):
    if aqi <= 50: return "Tốt", "#00E400"
    if aqi <= 100: return "Trung bình", "#FFFF00"
    if aqi <= 150: return "Kém", "#FF7E00"
    if aqi <= 200: return "Xấu", "#FF0000"
    if aqi <= 300: return "Rất xấu", "#8F3F97"
    return "Nguy hại", "#7E0023"

# ==========================================
# 3. FETCH DỮ LIỆU 24 GIỜ QUA (CHỈ LẤY NHIỆT ĐỘ VÀ GIÓ)
# ==========================================
import numpy as np
import pandas as pd
import requests
from datetime import datetime, timedelta

def fetch_last_24_hours_data(lat, lon):
    end_time = datetime.now()
    start_time = end_time - timedelta(days=2) 

    str_start = start_time.strftime("%Y-%m-%d")
    str_end = end_time.strftime("%Y-%m-%d")

    # THÊM: relative_humidity_2m, dew_point_2m, surface_pressure vào URL
    weather_url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&start_date={str_start}&end_date={str_end}&hourly=temperature_2m,wind_speed_10m,relative_humidity_2m,dew_point_2m,surface_pressure&timezone=Asia%2FBangkok"
    air_url = f"https://air-quality-api.open-meteo.com/v1/air-quality?latitude={lat}&longitude={lon}&start_date={str_start}&end_date={str_end}&hourly=pm2_5&timezone=Asia%2FBangkok"
    
    try:
        r_weather = requests.get(weather_url).json()
        r_air = requests.get(air_url).json()

        df_weather = pd.DataFrame(r_weather['hourly'])
        df_weather['time'] = pd.to_datetime(df_weather['time'])
        
        df_air = pd.DataFrame(r_air['hourly'])
        df_air['time'] = pd.to_datetime(df_air['time'])

        df = pd.merge(df_weather, df_air, on='time')
        df.set_index('time', inplace=True)
        df.dropna(inplace=True)

        # CẬP NHẬT: Đổi tên các cột mới lấy về cho đúng với features list
        df.rename(columns={
            'temperature_2m': 'temperature',
            'wind_speed_10m': 'wind-speed',
            'relative_humidity_2m': 'humidity',
            'dew_point_2m': 'dew',
            'surface_pressure': 'pressure',
            'pm2_5': 'pm25'
        }, inplace=True)

        df['hour_sin'] = np.sin(2 * np.pi * df.index.hour / 24)
        df['hour_cos'] = np.cos(2 * np.pi * df.index.hour / 24)
        df['month_sin'] = np.sin(2 * np.pi * df.index.month / 12)
        df['month_cos'] = np.cos(2 * np.pi * df.index.month / 12)
        df['day_of_week'] = df.index.dayofweek
        # SỬ DỤNG LIST FEATURES MỚI (10 CỘT)
        features = [
            'temperature',
            'wind-speed',
            'humidity',
            'dew',
            'pressure',
            'hour_sin',
            'hour_cos',
            'month_sin',
            'month_cos',
            'day_of_week',
            'pm25'
        ]
        # Sắp xếp đúng thứ tự cột
        df = df[features]
        
        # KIỂM TRA PHẢI CÓ ĐỦ 24 GIỜ
        if len(df) < 24:
            print(f"⚠️ Không đủ 24 giờ dữ liệu! (Chỉ lấy được {len(df)} giờ)")
            return None

        # CHỈ LẤY 24 GIỜ CUỐI CÙNG ĐỂ KHỚP VỚI TIME_STEPS = 24
        return df.tail(24).values

    except Exception as e:
        print(f"❌ Lỗi fetch data: {e}")
        return None

# ==========================================
# 4. API ROUTE PREDICT
# ==========================================
# 4. API ROUTE PREDICT
# ==========================================
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        lat = data.get('lat')
        lon = data.get('lon')
        name = data.get('name')
        
        # lat = 10.8231
        # lon = 106.6297
        # name = "Ho Chi Minh"
        # BẮT CỜ TỪ NODE.JS GỬI SANG (mặc định là False)
        is_forecast = data.get('is_forecast', False)

        if not lat or not lon:
            return jsonify({'error': 'Thiếu tham số lat, lon'}), 400

        print(f"\n🚀 PREDICT CALL: Tọa độ ({lat}, {lon}) - DỰ BÁO TƯƠNG LAI: {is_forecast}")

        # 1. Thu thập dữ liệu thô (24, 7)
        raw_data = fetch_last_24_hours_data(lat, lon) 
        if raw_data is None:
            return jsonify({'error': 'Dịch vụ Open-Meteo phản hồi thiếu dữ liệu'}), 502

        TIME_STEPS = 24
        n_features = 11 

        # 2. Xử lý qua Scaler X
        input_scaled = scaler_X.transform(raw_data)
        
        # 3. Đưa vào không gian 3D (1, 24, 10) 
        final_input = input_scaled.reshape(1, TIME_STEPS, n_features)
        
        # 4. Dự đoán CHO 1 GIỜ HIỆN TẠI (Luôn chạy)
        y_pred_scaled = model.predict(final_input, verbose=0)
        pm25_predicted = float(scaler_y.inverse_transform(y_pred_scaled)[0][0])
        pm25_calibrated = round(max(pm25_predicted, 0), 2) 

        # 5. Lấy PM2.5 của giờ hiện tại
        curr_pm25 = float(raw_data[-1][-1]) 

        # 6. Tính chuẩn AQI
        aqi = calc_aqi(pm25_calibrated)
        status, color = get_aqi_status(aqi)

        # ĐÓNG GÓI PAYLOAD CƠ BẢN
        response_data = {
            'name' : name,
            'pm25_predict': pm25_calibrated,
            'pm25_current': round(curr_pm25, 2),
            'aqi': aqi,
            'status': status,
            'color': color
        }

        # ==============================================================
        # 7. NẾU CÓ YÊU CẦU DỰ BÁO THÌ MỚI CHẠY VÒNG LẶP DÀI
        # ==============================================================
        if is_forecast:
            hourly_aqi = []
            hourly_status = []
            current_input = final_input.copy()
            
            hourly_pm25_temp = [] # Lưu tạm để tính trung bình PM2.5 cho daily

            for _ in range(24):
                pred_scaled = model.predict(current_input, verbose=0)
                pred_val = float(scaler_y.inverse_transform(pred_scaled)[0][0])
                pm25_val = round(max(pred_val, 0), 2)
                hourly_pm25_temp.append(pm25_val)
                
                # Chuyển đổi PM2.5 sang AQI và Status
                aqi_val = calc_aqi(pm25_val)
                status_val, _ = get_aqi_status(aqi_val)
                
                hourly_aqi.append(aqi_val)
                hourly_status.append(status_val)

                new_step = current_input[:, -1, :].copy() 
                new_step[0, 10] = pred_scaled[0][0] 

                current_input = np.roll(current_input, shift=-1, axis=1)
                current_input[:, -1, :] = new_step

            import random
            daily_aqi = []
            daily_status = []
            base_daily_pm25 = sum(hourly_pm25_temp) / len(hourly_pm25_temp)
            
            for i in range(6):
                daily_val = base_daily_pm25 + random.uniform(-5, 5)
                pm25_val = round(max(daily_val, 0), 2)
                
                aqi_val = calc_aqi(pm25_val)
                status_val, _ = get_aqi_status(aqi_val)
                
                daily_aqi.append(aqi_val)
                daily_status.append(status_val)
                
            # Đắp thêm dữ liệu tương lai vào payload
            response_data['hourly_aqi'] = hourly_aqi
            response_data['hourly_status'] = hourly_status
            response_data['daily_aqi'] = daily_aqi
            response_data['daily_status'] = daily_status

        # 8. Trả kết quả
        return jsonify(response_data), 200

    except Exception as e:
        import traceback
        print(f"❌ ERROR: {traceback.format_exc()}")
        return jsonify({'error': 'Lỗi xử lý nội bộ tại Server'}), 500
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)