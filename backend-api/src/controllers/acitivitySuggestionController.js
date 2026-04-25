const activitySuggestionService = require('../services/activitySuggestionService');

const handleActivitySuggestion = async (req, res) => {
    try{
        const {aqi,location} = req.body;

        const reply = await activitySuggestionService.getChatResponseActivity(aqi,location);

        return res.status(200).json({
            success: true,
            data:{
                reply:reply,
                locationUsed: location || 'Hồ Chí Minh'
            }
        })
    }
    catch(error){
        return res.status(500).json({
            success: false,
            message: error.message
        })
    }


}

module.exports = {handleActivitySuggestion}