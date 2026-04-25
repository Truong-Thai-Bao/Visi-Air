const {GoogleGenerativeAI} = require("@google/generative-ai");
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
console.log('loi',process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({model: "gemini-2.5-flash"});

const getChatResponseActivity = async (aqi, location) => {
    try{
        const systemPrompt = `
      Bạn là một chuyên gia sức khỏe và môi trường. 
      Hiện tại ở ${location}, chỉ số AQI là ${aqi}.
      Hãy đưa ra 5 lời khuyên hoạt động cụ thể cho người dân.
      
      Yêu cầu bắt buộc:
      1. Trả về kết quả CHỈ LÀ MỘT JSON ARRAY thuần túy (không markdown, không giải thích thêm) và ngắn gọn.
      2. Cấu trúc JSON: [{"id": "string", "title": "ngắn gọn, 2-3 từ", "description": "thân thiện và ngắn gọn", "iconType": "string", "level": "string"}]
      3. "iconType" chỉ được chọn trong các từ khóa sau: run, bike, yoga, park, swim, mask, home, food, travel.
      4. "level" chỉ được chọn: Tốt, Vừa phải, Cẩn thận, Xấu.
      5. Nội dung phải sáng tạo, đa dạng, phù hợp văn hóa Việt Nam.`

    const chat = model.startChat({
        history:[]
    })
    const result = await chat.sendMessage(systemPrompt);
    const res = result.response;
    return res.text();
    }
    catch(error){
        console.error("Lỗi ở ChatService:", error);
        throw new Error("Không thể kết nối với AI lúc này.");
    }
}

module.exports = {getChatResponseActivity};