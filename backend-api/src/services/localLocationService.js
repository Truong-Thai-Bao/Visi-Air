const removeAccents = require('../utils/helper');
const locationData = require('../data/location');


const localPayload = async (cityName)=>{
    if (!cityName) throw new Error("Thiếu tên thành phố");
    let lat, lon, finalName;
    console.log('p',cityName)
    const localCity = locationData.find(c => removeAccents.removeAccents(c.name).toLowerCase() === removeAccents.removeAccents(cityName).toLowerCase());
    if (localCity) {
        console.log("Tìm thấy trong dữ liệu nội bộ!");
        lat = localCity.lat;
        lon = localCity.lon;
        finalName = localCity.name;
    } 
    else {
        console.log("Đang tìm online...");
        const weatherService =  require('../services/weatherService');
        const geoData = await weatherService.getCoordinatesByCityName(cityName);
        
        if (!geoData) {
            return res.status(404).json({ 
            success: false, 
            message: `Không tìm thấy địa điểm: ${cityName}` 
            });
        }
        lat = geoData.lat;
        lon = geoData.lon;
        finalName = geoData.name;
    }
    console.log(finalName)
    return {
        lat: parseFloat(lat),
        lon: parseFloat(lon),
        name :finalName
    };
}
module.exports = {localPayload}