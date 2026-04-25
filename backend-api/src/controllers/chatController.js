const chatService = require('../services/chatService');

const handleChat = async (req, res) => {
  try {
    const { message, location } = req.body;

    if (!message||!location) {
      return res.status(400).json({ error: "Tin nhắn không được để trống!" });
    }

    const reply = await chatService.getChatResponse(message, location);

    return res.status(200).json({
        reply: reply,
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

module.exports = { handleChat };