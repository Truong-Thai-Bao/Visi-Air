const axios = require('axios');
const localLocationService = require('./localLocationService');
const helper = require('../utils/helper');


// 1. Hàm tìm toạ độ từ tên (Dùng Geocoding API)
const getCoordinatesByCityName = async (cityName) => {
  try {
    // Gọi API tìm kiếm địa danh (Open-Meteo Geocoding - Miễn phí, không cần Key)
    const url = `https://geocoding-api.open-meteo.com/v1/search?name=${cityName}&count=1&language=vi&format=json`;
    
    const response = await axios.get(url);
    const data = response.data;

    // Kiểm tra xem có tìm thấy địa điểm nào không
    if (!data.results || data.results.length === 0) {
      return null; // Không tìm thấy
    }

    // Lấy kết quả đầu tiên (chính xác nhất)
    const location = data.results[0];
    return {
      name: location.name,
      lat: location.latitude,
      lon: location.longitude,
    };

  } catch (error) {
    console.error("Lỗi Geocoding:", error.message);
    return null;
  }
};

const fetchWeather = async (name) => {
    try {
        const location = await localLocationService.localPayload(name);
        const lat = location.lat;
        const lon = location.lon;

        // 1. CẬP NHẬT URL: Thêm dew_point_2m vào tham số current
        const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code,dew_point_2m&hourly=temperature_2m,weather_code&wind_speed_unit=ms&timezone=auto`;
        
        const res = await axios.get(url);
        const data = res.data;

        const currentTime = data.current.time; 
        const hourlyTimes = data.hourly.time;
        const hourlyTemps = data.hourly.temperature_2m;
        const hourlyCodes = data.hourly.weather_code;

        // Tìm vị trí (index) của giờ hiện tại trong mảng lịch sử/dự báo 24h
        const currentHourPrefix = currentTime.substring(0, 13);
        const currentIndex = hourlyTimes.findIndex(time => time.startsWith(currentHourPrefix));

        const nextHoursForecast = [];

        // Nếu tìm thấy giờ hiện tại, bắt đầu lùi tới tương lai
        if (currentIndex !== -1) {
            // Lấy 4 mốc: +2h, +4h, +6h, +8h 
            for (let i = 2; i <= 10; i += 2) {
                const targetIndex = currentIndex + i;
                
                // Đảm bảo không lấy vượt quá giới hạn mảng của API
                if (targetIndex < hourlyTimes.length) {
                    const hourString = hourlyTimes[targetIndex].substring(11, 16);
                    
                    nextHoursForecast.push({
                        time: hourString,
                        temperature: hourlyTemps[targetIndex],
                        icon: helper.getWeatherIcon(hourlyCodes[targetIndex])
                    });
                }
            }
        }

        // 2. CẬP NHẬT CLEANDATA: Đóng gói đủ 5 biến theo yêu cầu của bạn
        const cleanData = {
            temperature: data.current.temperature_2m,
            humidity: data.current.relative_humidity_2m,
            wind_speed: data.current.wind_speed_10m,
            pressure: data.current.surface_pressure, // Đã bổ sung áp suất bề mặt
            dew: data.current.dew_point_2m,          // Đã bổ sung điểm sương
            time: data.current.time,
            icon: helper.getWeatherIcon(data.current.weather_code),
            forecast: nextHoursForecast 
        }
        return cleanData;

    } catch (error) {
        console.error("Lỗi gọi Open-Meteo:", error.message);
        throw new Error("Không thể lấy dữ liệu thời tiết.");
    }
}





module.exports = {fetchWeather,getCoordinatesByCityName};