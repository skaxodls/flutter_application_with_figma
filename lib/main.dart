import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDio(); // ✅ 앱 실행 전 Dio 세션/쿠키 설정
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fish Go',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // 시작 화면
    );
  }
}
