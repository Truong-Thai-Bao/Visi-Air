const searchService = require('../services/searchService');

const search = async (req, res) => {
    try {
        // Lấy cityName từ `req.params` cho GET request, thay vì `req.body`
        const cityName = req.params.name || null;

        const searchRes = await searchService.searchCityAQI(cityName);
        console.log(searchRes)
        return res.status(200).json({
            success: true,
            data : searchRes
        })
    } catch (err) {
        // Cải thiện xử lý lỗi: Ghi log chi tiết và trả về lỗi 500 cho client
        console.error('Lỗi tại search controller:', err.message);
        return res.status(500).json({
            success: false,
            message: 'Lỗi hệ thống khi tìm kiếm.'
        });
    }
};

module.exports = { search };