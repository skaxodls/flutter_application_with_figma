import 'package:flutter/material.dart';
import 'dart:io';
import 'fish_detail_screen.dart';

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

  // 3초 후 FishDetailScreen으로 이동
  void _simulateProcessing() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FishDetailScreen(
            fishNumber: 1, // 임시 번호
            fishName: "넙치농어", // 임시 물고기명
            scientificName: "Lateolabrax japonicus", // 임시 학명
            morphologicalInfo: "머리부터 뒷줄까지 오로라한 C", // 형태생태정보 (추후 API 연동 가능)
            taxonomy: "동물계 > 척삭동물문 > 십자선어목 > 농어과", // 분류 (추후 API 연동 가능)
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
          children: const [
            CircularProgressIndicator(), // 로딩 애니메이션
            SizedBox(height: 16),
            Text(
              "이미지 처리 중...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
