const axios = require('axios');
const localLocationService = require('./localLocationService');
const redis = require('redis');
require('dotenv').config();
// Địa chỉ Python Server
const PYTHON_API_URL = process.env.PYTHON_API_URL;
const REDIS_URL = process.env.REDIS_URL;
//Connect to redis server
const redisClient = redis.createClient({ url: REDIS_URL });

redisClient.on('error',(err)=>console.log('Loi redis: ',err));
redisClient.on('connect',()=>console.log('Ket noi thanh cong: '));
// Kết nối chạy ngầm
redisClient.connect().catch(console.error);

const getPrediction = async (cityName,is_forecast = false) => {
    try {
        //Tạo key
        const cacheKey = `aqi:${cityName.toLowerCase()}:forecast_${is_forecast}`;

        //Tìm xem redis tồn tại
        const cachedData = await redisClient.get(cacheKey);
        //Nếu tồn tại rồi
        if(cachedData){
            return JSON.parse(cachedData);
        } 

        const payload = await localLocationService.localPayload(cityName); 
        payload.is_forecast = is_forecast;
        const pythonResponse = await axios.post(PYTHON_API_URL, payload, {
            timeout: 100000 // Timeout sau 10s
        });
        const finalData =  pythonResponse.data;

        //Lưu redis trong 10 phút
        await redisClient.setEx(cacheKey,600,JSON.stringify(finalData));

        return finalData;
    } catch (error) {
        // Xử lý lỗi chi tiết hơn
        if (error.code === 'ECONNREFUSED') {
            throw new Error("Không thể kết nối tới AI Server (Python). Vui lòng kiểm tra server Python đã bật chưa.");
        }
        console.error("Lỗi tại PredictService:", error.message);
        throw error;
    }
};

module.exports = { getPrediction };