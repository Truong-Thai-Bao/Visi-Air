const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController')
const activitySuggestionController = require('../controllers/acitivitySuggestionController')
const weatherController = require('../controllers/weatherController')
const predictController = require('../controllers/predictController')
const forecastController = require('../controllers/forecastController');
const searchController  = require('../controllers/searchController');




router.post('/chat', chatController.handleChat);
router.post('/activitySuggestion',activitySuggestionController.handleActivitySuggestion)
router.post('/current',weatherController.getWeatherByCityName)
router.post('/forecast',forecastController.getForcast)
router.get('/predict',predictController.getAqiPrediction)
router.get('/search/',searchController.search);
router.get('/search/:name',searchController.search);


module.exports = router;