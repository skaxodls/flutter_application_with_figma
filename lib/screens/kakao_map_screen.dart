import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({Key? key}) : super(key: key);

  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late final WebviewController _controller;
  bool _isWebViewInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = WebviewController();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      await _controller.initialize();
      print("✅ WebView2 초기화 완료");

      // ✅ Flutter에서 JavaScript 메시지 수신 (WebView2)
      _controller.webMessage.listen((message) {
        print("📌 WebView에서 받은 데이터: $message");

        try {
          // ✅ JSON 문자열을 객체로 변환
          final Map<String, dynamic> addressData = jsonDecode(message);

          // ✅ 원하는 형식으로 변환 (가게이름 : 상세주소)
          final String formattedAddress =
              "${addressData['addressName']} (${addressData['detailedAddress']})";

          print("📌 변환된 주소: $formattedAddress");

          // ✅ 변환된 데이터를 Flutter로 반환
          Navigator.pop(context, formattedAddress);
        } catch (e) {
          print("❌ JSON 파싱 오류: $e");
        }
      });

      // ✅ Flask 서버의 kakao_map.html 로드
      await _controller.loadUrl('http://127.0.0.1:5000/kakao_map.html');

      setState(() {
        _isWebViewInitialized = true;
      });
    } catch (e) {
      print("❌ WebView 초기화 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("낚시 포인트 선택")),
      body: _isWebViewInitialized
          ? SizedBox.expand(child: Webview(_controller))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
