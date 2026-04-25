import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/activity_suggestion.dart';

class ActivityService {
  // ⚠️ QUAN TRỌNG: Bạn hãy lấy API Key miễn phí tại https://aistudio.google.com/
  static const String _apiKey = 'AIzaSyD9HheTQBJwHf9aBcC-AwFqnQDEnz0Zygg';

  // Hàm chính để lấy dữ liệu (Ưu tiên AI, nếu lỗi thì dùng dữ liệu cứng)
  Future<List<ActivitySuggestion>> fetchActivities(
    int aqi,
    String location,
  ) async {
    try {
      // 1. Thử gọi AI để lấy nội dung phong phú
      return await _fetchFromGemini(aqi, location);
    } catch (e) {
      print("Lỗi AI: $e. Chuyển sang dữ liệu mặc định.");
      // 2. Nếu lỗi (mất mạng, hết quota), trả về dữ liệu cứng
      return _getFallbackData(aqi);
    }
  }

  // --- GỌI GOOGLE GEMINI API ---
  Future<List<ActivitySuggestion>> _fetchFromGemini(
    int aqi,
    String location,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

    // Kỹ thuật Prompt Engineering: Yêu cầu AI trả về đúng định dạng JSON
    final prompt =
        '''
      Bạn là một chuyên gia sức khỏe và môi trường. 
      Hiện tại ở "$location", chỉ số AQI là $aqi.
      Hãy đưa ra 5 lời khuyên hoạt động cụ thể cho người dân.
      
      Yêu cầu bắt buộc:
      1. Trả về kết quả CHỈ LÀ MỘT JSON ARRAY thuần túy (không markdown, không giải thích thêm) và ngắn gọn.
      2. Cấu trúc JSON: [{"id": "string", "title": "ngắn gọn, 2-3 từ", "description": "thân thiện và ngắn gọn", "iconType": "string", "level": "string"}]
      3. "iconType" chỉ được chọn trong các từ khóa sau: run, bike, yoga, park, swim, mask, home, food, travel.
      4. "level" chỉ được chọn: Tốt, Vừa phải, Cẩn thận, Xấu.
      5. Nội dung phải sáng tạo, đa dạng, phù hợp văn hóa Việt Nam.
    ''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    final responseText = response.text;
    if (responseText == null) throw Exception("Empty response");

    // Xử lý chuỗi JSON trả về (đôi khi AI thêm ```json ở đầu, cần lọc bỏ)
    String jsonString = responseText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map(
          (item) => ActivitySuggestion(
            id: item['id'].toString(),
            title: item['title'],
            description: item['description'],
            iconType: item['iconType'],
            level: item['level'],
          ),
        )
        .toList();
  }

  // --- DỮ LIỆU CỨNG (FALLBACK) ---
  // Dùng khi không có mạng hoặc chưa có API Key
  List<ActivitySuggestion> _getFallbackData(int aqi) {
    if (aqi <= 50) {
      return [
        ActivitySuggestion(
          id: '1',
          title: "Chạy bộ công viên",
          description:
              "Không khí Hóc Môn hôm nay tuyệt vời! Xách giày lên và chạy ngay đi.",
          iconType: 'run',
          level: 'Tốt',
        ),
        ActivitySuggestion(
          id: '2',
          title: "Cà phê vỉa hè",
          description:
              "Thời tiết đẹp, rất thích hợp ngồi cà phê ngắm phố phường.",
          iconType: 'food',
          level: 'Tốt',
        ),
        ActivitySuggestion(
          id: '3',
          title: "Đạp xe thư giãn",
          description: "Lý tưởng cho một vòng đạp xe quanh hồ.",
          iconType: 'bike',
          level: 'Tốt',
        ),
      ];
    } else if (aqi > 150) {
      return [
        ActivitySuggestion(
          id: '4',
          title: "Đeo khẩu trang chuẩn",
          description:
              "Bụi mịn đang cao. Hãy đeo khẩu trang N95 nếu bắt buộc phải ra ngoài.",
          iconType: 'mask',
          level: 'Xấu',
        ),
        ActivitySuggestion(
          id: '5',
          title: "Đóng cửa sổ",
          description: "Nên bật máy lọc không khí và hạn chế mở cửa.",
          iconType: 'home',
          level: 'Cẩn thận',
        ),
      ];
    } else {
      return [
        ActivitySuggestion(
          id: '6',
          title: "Đi bộ nhẹ nhàng",
          description:
              "Chất lượng không khí ở mức trung bình, vẫn ổn cho người khỏe mạnh.",
          iconType: 'run',
          level: 'Vừa phải',
        ),
        ActivitySuggestion(
          id: '7',
          title: "Yoga tại nhà",
          description: "Nếu bạn nhạy cảm, một buổi Yoga trong nhà sẽ tốt hơn.",
          iconType: 'yoga',
          level: 'Vừa phải',
        ),
      ];
    }
  }
}
