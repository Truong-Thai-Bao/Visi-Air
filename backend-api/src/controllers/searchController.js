const searchService = require('../services/searchService');

const search = async (req, res) => {
    try {
        const cityName = req.params.name || null;

        const searchRes = await searchService.searchCityAQI(cityName);
        console.log(searchRes)
        return res.status(200).json({
            success: true,
            data : searchRes
        })
    } catch (err) {
        console.error('Lỗi tại search controller:', err.message);
        return res.status(500).json({
            success: false,
            message: 'Lỗi hệ thống khi tìm kiếm.'
        });
    }
};

module.exports = { search };