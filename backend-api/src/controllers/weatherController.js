// src/controllers/weatherController.js
const weatherService = require('../services/weatherService');
const predictService = require('../services/predictService')
const helper = require('../utils/helper');

const getWeatherByCityName = async (req, res) => {
  try {
    const cityName = req.body.name;
    if(!cityName){
      return res.status(400).json({
        success:false,
        message :"Không tìm thấy tên thành phố ở controller"
      })
    }
    const weatherData = await weatherService.fetchWeather(cityName);
    const predict = await predictService.getPrediction(cityName);
    predict.advice = helper.getHealthAdvice(predict.status);

    res.status(200).json({
      success: true,
      data: {
        weather: weatherData,
        predict:predict
      }
    });

  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};



module.exports = { getWeatherByCityName, getCities: (req, res) => res.json({ data: cities }) };