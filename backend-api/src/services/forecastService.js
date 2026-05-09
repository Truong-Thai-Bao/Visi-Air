const axios = require('axios');
const localLocationService = require('./localLocationService')
const helper = require('../utils/helper')
const predictService = require('./predictService'); // Bổ sung import này ở đầu file

const getForecastData = async (cityName) => {
    try {
        const localLocation = await localLocationService.localPayload(cityName);
        const lat = localLocation.lat;
        const lon = localLocation.lon;

        const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=weather_code&daily=weather_code&timezone=Asia%2FHo_Chi_Minh&forecast_days=6`;
        
        const [weatherResponse, aiPrediction] = await Promise.all([
            axios.get(url).then(res => res.data),
            predictService.getPrediction(cityName,true) // Gọi sang Python
        ]);

        if (weatherResponse.error) {
            throw new Error(weatherResponse.reason);
        }

       console.log('hi')
        // Fallback an toàn nếu Python chưa kịp code mảng (tránh sập app)
        const hourlyAqiArray = aiPrediction.hourly_aqi || Array(24).fill("--");
        const dailyAqiArray = aiPrediction.daily_aqi || Array(6).fill("--");

        // --- XỬ LÝ DỮ LIỆU HOURLY (HÔM NAY) ---
        const hourlyData = [];
        
        // Lấy giờ hiện tại từ dữ liệu API (đã đúng múi giờ Asia/Ho_Chi_Minh)
        const now = new Date(weatherResponse.hourly.time[0]); // Lấy timestamp đầu tiên
        const currentTime = new Date();
        
        // Tìm index của giờ hiện tại hoặc giờ kế tiếp
        let startIndex = 0;
        for (let i = 0; i < weatherResponse.hourly.time.length; i++) {
            const forecastTime = new Date(weatherResponse.hourly.time[i]);
            if (forecastTime.getTime() > currentTime.getTime()) {
                startIndex = i;
                break;
            }
        }

        for (let i = 0; i < 5; i++) {
            const index = startIndex + i;
            if (index < weatherResponse.hourly.time.length) {
                const timeString = weatherResponse.hourly.time[index];
                
                // Trích xuất AQI dự báo từ mảng của AI
                let predictedAqi = hourlyAqiArray[index] !== "--" ? Math.round(hourlyAqiArray[index]) : "--";

                hourlyData.push({
                    time: `${String(new Date(timeString).getHours()).padStart(2, '0')}:00`,
                    temperature: predictedAqi, // Vẫn giữ key 'temperature' để Flutter khỏi lỗi gạch đỏ, nhưng value là AQI
                    icon: helper.getWeatherIcon(weatherResponse.hourly.weather_code[index])
                });
            }
        }

        // --- XỬ LÝ DỮ LIỆU DAILY (DỰ BÁO SẮP TỚI) ---
        const dailyData = [];
        for (let i = 1; i < 6; i++) {
            const dateStr = weatherResponse.daily.time[i];
            
            let predictedDailyAqi = dailyAqiArray[i] !== "--" ? Math.round(dailyAqiArray[i]) : "--";

            dailyData.push({
                dayOfWeek: helper.getVNDayOfWeek(dateStr),
                date: helper.formatDateVN(dateStr),
                temperature: predictedDailyAqi, // Giá trị thực tế là AQI
                icon: helper.getWeatherIcon(weatherResponse.daily.weather_code[i])
            });
        }

        return {
            today: hourlyData,
            upcoming: dailyData
        };

    } catch (error) {
        console.error("Lỗi khi kết hợp dữ liệu Forecast & AI:", error);
        throw error;
    }
};

module.exports = { getForecastData };
