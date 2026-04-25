const { GoogleGenerativeAI } = require("@google/generative-ai");
// require('dotenv').config();

// Khởi tạo SDK một lần
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

const getChatResponse = async (userMessage, location) => {
  try {
    // 1. Tạo Prompt hệ thống (System Instruction)
    const systemPrompt = `
      Bạn là VisiAir Assistant, trợ lý ảo về thời tiết và sức khỏe.
      Hiện tại người dùng đang ở khu vực: ${location || "Hồ Chí Minh"}.
      Hãy trả lời ngắn gọn, thân thiện, sử dụng emoji.
      Nếu câu hỏi liên quan đến thời tiết, hãy ưu tiên tư vấn cho khu vực ${location || "Hồ Chí Minh"}.
      Luôn kèm theo một lời khuyên sức khỏe ngắn gọn.
      TUYỆT ĐỐI KHÔNG sử dụng định dạng Markdown (như dấu **, *, #). Chỉ trả lời bằng văn bản thuần túy (plain text).
    `;

    // 2. Cấu hình cuộc hội thoại
    // (Ở đây ta giả lập lịch sử chat ngắn để tạo ngữ cảnh)
    const chat = model.startChat({
      history: [
        {
          role: "user",
          parts: [{ text: systemPrompt }],
        },
        {
          role: "model",
          parts: [{ text: "Ok, tôi đã hiểu. Tôi sẽ hỗ trợ dựa trên vị trí " + location }],
        },
      ],
    });

    // 3. Gửi tin nhắn và chờ phản hồi
    const result = await chat.sendMessage(userMessage);
    const response = result.response;
    return response.text(); // Trả về text sạch

  } catch (error) {
    console.error("Lỗi ở ChatService:", error);
    throw new Error("Không thể kết nối với AI lúc này.");
  }
};

module.exports = { getChatResponse };