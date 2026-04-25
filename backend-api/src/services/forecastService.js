const localLocationService = require('./localLocationService')
const helper = require('../utils/helper')
const predictService = require('./predictService'); // Bổ sung import này ở đầu file

const getForecastData = async (cityName) => {
    try {
        const localLocation = await localLocationService.localPayload(cityName);
        const lat = localLocation.lat;
        const lon = localLocation.lon;

        // TỐI ƯU 1: Bỏ lấy temperature từ Open-Meteo cho nhẹ, chỉ lấy weather_code làm Icon
        const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=weather_code&daily=weather_code&timezone=Asia%2FHo_Chi_Minh&forecast_days=6`;
        
        // TỐI ƯU 2: CHẠY SONG SONG CẢ 2 API (Open-Meteo và Python AI)
        const [weatherResponse, aiPrediction] = await Promise.all([
            fetch(url).then(res => res.json()),
            predictService.getPrediction(cityName,true) // Gọi sang Python
        ]);

        if (weatherResponse.error) {
            throw new Error(weatherResponse.reason);
        }

       
        // Fallback an toàn nếu Python chưa kịp code mảng (tránh sập app)
        const hourlyAqiArray = aiPrediction.hourly_aqi || Array(24).fill("--");
        const dailyAqiArray = aiPrediction.daily_aqi || Array(6).fill("--");

        // --- XỬ LÝ DỮ LIỆU HOURLY (HÔM NAY) ---
        const hourlyData = [];
        const currentHour = new Date().getHours();
        
        let startIndex = weatherResponse.hourly.time.findIndex(time => new Date(time).getHours() === currentHour);
        if (startIndex === -1) startIndex = 0;

        for (let i = 0; i < 5; i++) {
            const index = startIndex + (i * 2);
            if (index < weatherResponse.hourly.time.length) {
                const timeString = weatherResponse.hourly.time[index];
                
                // Trích xuất AQI dự báo từ mảng của AI
                let predictedAqi = hourlyAqiArray[i * 2] !== "--" ? Math.round(hourlyAqiArray[i * 2]) : "--";

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
