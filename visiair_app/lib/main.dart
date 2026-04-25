// lib/main.dart
import 'package:flutter/material.dart';
import './screens/onboarding/onboarding.dart'; // Import màn hình vừa tạo
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisiAir',
      debugShowCheckedModeBanner: false, // Tắt chữ debug ở góc
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const OnboardingScreen(), // Chạy màn hình này đầu tiên
    );
  }
}
