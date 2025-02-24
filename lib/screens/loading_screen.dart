import 'package:flutter/material.dart';
import 'dart:io';
import 'fish_detail_screen.dart'; // ✅ 물고기 상세 화면 임포트

class LoadingScreen extends StatefulWidget {
  final File selectedImage;

  const LoadingScreen({super.key, required this.selectedImage});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _simulateProcessing();
  }

  // ✅ 3초 후 FishDetailScreen으로 이동
  void _simulateProcessing() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FishDetailScreen(
            fishNumber: 1, // ✅ 임시 번호
            fishName: "넙치농어", // ✅ 분석된 물고기명 (추후 모델 결과 적용 가능)
            scientificName: "Lateolabrax japonicus", // ✅ 임시 학명
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(), // ✅ 로딩 애니메이션
            const SizedBox(height: 16),
            const Text(
              "이미지 처리 중...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
