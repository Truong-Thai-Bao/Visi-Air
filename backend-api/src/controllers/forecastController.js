const forcastService = require('../services/forecastService')

const getForcast = async (req,res) => {
  try{
    const cityName = req.body.name;
    if(!cityName){
      return res.status(400).json({
        success:false,
        message :"Không tìm thấy tên thành phố ở controller"
      })
    }
    const forcastData = await forcastService.getForecastData(cityName);
    console.log(forcastData)
    return res.status(200).json({
      message:"success",
      data:forcastData
    })
  }catch(error){
    console.error("Lỗi trong getForcast controller:", error);
    return res.status(500).json({message:"Lỗi lấy dữ liệu forcast ở controller"});
  }
}

module.exports = {getForcast}