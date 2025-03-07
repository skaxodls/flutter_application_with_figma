// import 'package:flutter/material.dart';
// // import 'package:webview_flutter_windows/webview_flutter_windows.dart';
// import 'package:webview_windows/webview_windows.dart';

// class KakaoMapScreen extends StatefulWidget {
//   const KakaoMapScreen({Key? key}) : super(key: key);

//   @override
//   _KakaoMapScreenState createState() => _KakaoMapScreenState();
// }

// class _KakaoMapScreenState extends State<KakaoMapScreen> {
//   late WebviewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebviewController();
//     _initWebView();
//   }

//   Future<void> _initWebView() async {
//     await _controller.initialize();
//     await _controller.loadUrl('https://map.kakao.com/');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("카카오 지도")),
//       body: SizedBox.expand(
//         child: Webview(_controller),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:webview_flutter/webview_flutter.dart';

// // class KakaoMapScreen extends StatefulWidget {
// //   const KakaoMapScreen({Key? key}) : super(key: key);

// //   @override
// //   _KakaoMapScreenState createState() => _KakaoMapScreenState();
// // }

// // class _KakaoMapScreenState extends State<KakaoMapScreen> {
// //   late final WebViewController _controller;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _controller = WebViewController()
// //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //       // ✅ JavaScript 메시지 채널 등록
// //       ..addJavaScriptChannel(
// //         "FlutterChannel",
// //         onMessageReceived: (message) {
// //           // ✅ 지도에서 클릭한 주소가 message.message로 넘어옴
// //           Navigator.pop(context, message.message);
// //         },
// //       )
// //       // ✅ Flask 서버에서 제공하는 kakao_map.html (카카오 지도 연동)
// //       ..loadRequest(Uri.parse('http://127.0.0.1/kakao_map.html'));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("낚시 포인트 선택")),
// //       body: WebViewWidget(controller: _controller),
// //     );
// //   }
// // }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_windows/webview_windows.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({Key? key}) : super(key: key);

  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late WebviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebviewController();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // assets 폴더의 HTML 파일 내용 로드
    String htmlContent = await rootBundle.loadString('assets/kakao_map.html');
    // HTML 문자열을 Base64로 인코딩
    String base64Html = base64Encode(utf8.encode(htmlContent));

    // WebView2 엔진 초기화
    await _controller.initialize();
    // Data URI 스킴을 사용해 인코딩된 HTML 로드
    await _controller.loadUrl('data:text/html;base64,$base64Html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("카카오 지도")),
      body: SizedBox.expand(
        child: Webview(_controller),
      ),
    );
  }
}
