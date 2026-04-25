import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/chat_service.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.location});
  final String location;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ChatService với địa điểm nhận được
    _chatService = ChatService(location: widget.location);
  }

  // Danh sách tin nhắn (Lưu cục bộ để hiển thị)
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Danh sách câu hỏi gợi ý (Dynamic Variable - sau này có thể gọi API để thay đổi list này)
  final List<String> _suggestedQuestions = [
    "Thời tiết hôm nay thế nào?",
    "Chất lượng không khí ra sao?",
    "Tôi nên mặc gì hôm nay?",
    "Có nên mang ô không?",
    "Gợi ý hoạt động cuối tuần",
    "Đặt vị trí mặc định",
  ];

  // Hàm gửi tin nhắn
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text}); // Thêm tin nhắn người dùng
      _isLoading = true;
    });
    _controller.clear();

    // Gọi API Gemini
    final response = await _chatService.sendMessage(text);

    String parsedReply = response;
    try {
      // Decode chuỗi JSON
      final Map<String, dynamic> decodedJson = jsonDecode(response);

      // Kiểm tra và lấy ra nội dung nằm trong key "reply"
      if (decodedJson.containsKey('reply')) {
        parsedReply = decodedJson['reply'];
      }
    } catch (e) {
      // Nếu có lỗi (ví dụ backend vô tình trả về text thường không phải JSON),
      // thì giữ nguyên response gốc để không bị sập app.
      debugPrint("Lỗi parse JSON: $e");
    }

    setState(() {
      _messages.add({
        "role": "ai",
        "text": parsedReply,
      }); // Thêm tin nhắn AI đã được lọc sạch
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar đơn giản
      appBar: AppBar(
        title: const Text(
          "AI Trợ lý thời tiết",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear(); // Xóa lịch sử chat để bắt đầu lại
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlue, Color.fromARGB(255, 1, 24, 59)],
          ),
        ),
        child: Column(
          children: [
            // --- PHẦN NỘI DUNG CHAT ---
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeView() // Nếu chưa chat -> Hiện gợi ý
                  : _buildChatList(), // Nếu đã chat -> Hiện list tin nhắn
            ),

            // --- THANH NHẬP LIỆU ---
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // 1. Giao diện Chào mừng & Gợi ý (Giống ảnh 1)
  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thẻ chào mừng
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 40),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Trợ lý thời tiết",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Xin chào! Tôi có thể giúp bạn kiểm tra thời tiết, AQI và đưa ra lời khuyên. Bạn muốn hỏi gì? 😉",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Câu hỏi gợi ý:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),

          // Danh sách các câu hỏi gợi ý
          ..._suggestedQuestions.map(
            (question) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _sendMessage(question), // Bấm vào là gửi luôn
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        question,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white30,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Giao diện Danh sách tin nhắn (Giống ảnh 2)
  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          // Hiển thị 3 chấm loading khi đang chờ AI
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final msg = _messages[index];
        final isUser = msg['role'] == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(15),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white, // User: mờ, AI: trắng
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Text(
              msg['text']!,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
          ),
        );
      },
    );
  }

  // 3. Khu vực nhập liệu dưới cùng
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F2648), // Màu nền đậm của thanh điều hướng
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => _sendMessage(_controller.text),
            backgroundColor: AppColors.primaryBlue,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
