import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_application_with_figma/dio_setup.dart';
import 'fish_detail_screen.dart';
import 'select_photo_screen.dart';
import 'package:dio/dio.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  final File selectedImage;

  const LoadingScreen({super.key, required this.selectedImage});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late int fishId;
  late String fishName;
  late double confidence;
  late String scientificName;
  late String morphologicalInfo;
  late String taxonomy;

  @override
  void initState() {
    super.initState();
    _classifyFish(); // ✅ 물고기 분류 진행
  }

  // ✅ 서버에 이미지 업로드 후 예측 결과 받아오기 (Dio 사용)
  Future<void> _classifyFish() async {
    final String url = '/predict'; // baseUrl과 결합되어 요청됨
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(widget.selectedImage.path),
    });

    try {
      Response response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        // ✅ API 응답 JSON 터미널 출력 (가독성을 위해 포맷팅)
        print("🔹 서버 응답 JSON:\n${jsonEncode(jsonResponse)}");

        // ✅ 서버에서 받은 결과 저장
        fishId = jsonResponse['fish_id'] ?? 0;
        fishName = jsonResponse['predicted_class'];
        confidence = jsonResponse['confidence'];
        scientificName = jsonResponse['scientific_name'] ?? "알 수 없음";
        morphologicalInfo = jsonResponse['morphological_info'] ?? "정보 없음";
        taxonomy = jsonResponse['taxonomy'] ?? "정보 없음";

        // ✅ 예측 결과 팝업 창 띄우기
        _showPredictionDialog();
      } else {
        _showError("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      // 서버 요청 실패 시 팝업을 띄우고 이미지 재선택 화면으로 이동
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("오류"),
          content: const Text("물고기 탐지에 실패하였습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectPhotoScreen(),
                  ),
                );
              },
              child: const Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  // ✅ 잡은 물고기 추가 함수
  Future<void> _insertCaughtFish(int fishId) async {
    try {
      final response = await dio.post(
        '/api/caught_fish',
        data: {
          "fish_id": fishId,
          "registered": true,
        },
      );

      if (response.statusCode == 200) {
        print("✅ 잡은 물고기 테이블에 추가 성공!");
      } else {
        print("❌ 잡은 물고기 테이블 추가 실패: ${response.data}");
      }
    } catch (e) {
      print("❌ 오류 발생: $e");
    }
  }

  // ✅ "맞아요" 버튼 눌렀을 때: 잡은 물고기 테이블에 추가 후 상세 화면으로 이동
  Future<void> _handleFishConfirmation() async {
    Navigator.pop(context); // 팝업 닫기
    await _insertCaughtFish(fishId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FishDetailScreen(
          fishNumber: fishId,
          fishName: fishName,
          scientificName: scientificName,
          morphologicalInfo: morphologicalInfo,
          taxonomy: taxonomy,
        ),
      ),
    );
  }

  Future<void> _navigateToHomeScreen() async {
    Navigator.pop(context);
    await _insertCaughtFish(fishId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // ✅ 예측 결과 팝업 띄우기
  void _showPredictionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 팝업 밖을 눌러 닫지 못하게 함
      builder: (context) {
        return AlertDialog(
          title: const Text("예측 결과"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(widget.selectedImage, height: 150),
              const SizedBox(height: 10),
              Text(
                "물고기명: $fishName",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "학술명: $scientificName",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                "예측 확률: ${(confidence).toStringAsFixed(2)}%",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // "맞아요" 버튼: 잡은 물고기 추가 후 상세 화면 이동
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _handleFishConfirmation,
                          child: const Text("상세 정보"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "아니에요" 버튼: 이미지 다시 선택 화면으로 이동
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _navigateToHomeScreen,
                          child: const Text("확인"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ 오류 발생 시 사용자에게 메시지 표시
  void _showError(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("오류 발생"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          );
        },
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
            CircularProgressIndicator(), // ✅ 로딩 애니메이션
            SizedBox(height: 16),
            Text(
              "이미지 분석 중...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
