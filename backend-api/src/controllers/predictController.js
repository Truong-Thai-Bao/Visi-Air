const predictService = require('../services/predictService');

const getAqiPrediction = async (req, res) => {
  try {
    const cityName = req.query.name;
    if(!cityName){
      return res.status(400).json({
        success:false,
        message :"Không tìm thấy tên thành phố ở controller"
      })
    }
    const result = await predictService.getPrediction(cityName);


    // Trả kết quả
    res.status(200).json({
        success: true,
        location_name: cityName || "Custom Coordinates",
        ...result 
    });

  } catch (error) {
    console.error("❌ Lỗi Controller:", error.message);
    
    const pythonError = error.response?.data?.error;
    const clientMessage = pythonError || error.message || "Lỗi hệ thống dự đoán";

    res.status(500).json({ 
      success: false, 
      message: clientMessage
    });
  }
};

module.exports = { getAqiPrediction };