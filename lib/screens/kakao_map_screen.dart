import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({Key? key}) : super(key: key);

  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://map.kakao.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("낚시 포인트 선택")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
