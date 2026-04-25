const predictService = require('./predictService');
const locations = require('../data/location'); 
const helper = require('../utils/helper')

const searchCityAQI = async (cityName) => {
    try {
        //Nếu chưa nhập gì thì load kết quả dự đoán 5 thành phố
        if (!cityName || cityName.trim() === "") {
            //Sử dụng promise để tăng tốc độ 
            const promises = locations.map(async (city) => {
                try {
                    const data = await predictService.getPrediction(city.name);
                    return {
                        name: city.name,
                        pm25_predict: data.pm25_predict,
                        aqi: data.aqi,
                        status: data.status,
                        color: data.color,
                        advice: helper.getHealthAdvice(data.status)
                    };
                } catch (error) {
                    console.error(`Lỗi khi dự đoán cho ${city.name}:`, error.message);
                    return null; 
                }
            });

            const results = await Promise.all(promises);
            return results.filter(item => item !== null);
        } 
        
        //Nếu search thì chỉ hiện 1 thành phố
        else {
            const data = await predictService.getPrediction(cityName);
            
            return [{
                name: data.name,
                pm25_predict: data.pm25_predict,
                aqi: data.aqi,
                status: data.status,
                color: data.color,
                advice: helper.getHealthAdvice(data.status)
            }];
        }
    } catch (error) {
        console.error("Lỗi tại searchService:", error.message);
        throw error;
    }
};

module.exports = { searchCityAQI };