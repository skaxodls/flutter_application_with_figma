import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fish_detail_screen.dart';
import 'select_photo_screen.dart';

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

  // ✅ 서버에 이미지 업로드 후 예측 결과 받아오기
  Future<void> _classifyFish() async {
    final url = Uri.parse("http://127.0.0.1:5000/predict"); // Flask API 주소
    var request = http.MultipartRequest('POST', url);
    request.files.add(
        await http.MultipartFile.fromPath('image', widget.selectedImage.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        // ✅ API 응답 JSON 터미널 출력 (가독성을 위해 포맷팅)
        print("🔹 서버 응답 JSON:\n${jsonEncode(jsonResponse)}");

        // ✅ 서버에서 받은 결과 저장
        fishId = jsonResponse['fish_id'] ?? 0;
        fishName = jsonResponse['predicted_class'];
        confidence = jsonResponse['confidence'];
        scientificName = jsonResponse['scientific_name'] ?? "알 수 없음";
        morphologicalInfo = jsonResponse['morphological_info'] ?? "정보 없음";
        taxonomy = jsonResponse['taxonomy'] ?? "정보 없음";

        // ✅ 팝업 창 띄우기
        _showPredictionDialog();
      } else {
        _showError("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      _showError("서버 요청 실패: $e");
    }
  }

  void _navigateToSelectImageScreen() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SelectPhotoScreen()),
    );
  }

  // ✅ 예측 결과 팝업 띄우기
  void _showPredictionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("예측 결과"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(widget.selectedImage, height: 150),
              const SizedBox(height: 10),
              Text("물고기명: $fishName",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text("학술명: $scientificName",
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text("예측 확률: ${(confidence).toStringAsFixed(2)}%",
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: EdgeInsets.zero,
          actions: [
            // 버튼들을 감싸는 Container (팝업창과 버튼 사이 여백 조절)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "모르겠어요" 버튼 (이제 "맞아요"와 동일한 동작 수행)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 122, 127, 131),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _navigateToDetailScreen, // ✅ "맞아요"와 동일하게 변경
                    child: const Text("모르겠어요"),
                  ),
                  const SizedBox(height: 8),
                  // "맞아요"와 "아니에요" 버튼 (기존과 동일)
                  Row(
                    children: [
                      // "맞아요" 버튼
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 219, 97, 70),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _navigateToDetailScreen,
                          child: const Text("맞아요"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "아니에요" 버튼 (이제 기존 "모르겠어요" 동작 수행)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              _navigateToSelectImageScreen, // ✅ 기존 "모르겠어요" 동작 수행
                          child: const Text("아니에요"),
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

  // ✅ `FishDetailScreen`으로 이동
  void _navigateToDetailScreen() {
    Navigator.pop(context); // 팝업 닫기
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
