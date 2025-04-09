import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

// Windows 전용 웹뷰 패키지
import 'package:webview_windows/webview_windows.dart';
// 모바일(Android/iOS) 전용 웹뷰 패키지 (최신 API 사용)
import 'package:webview_flutter/webview_flutter.dart';

class AddressSearchScreen extends StatefulWidget {
  final Function(String) onAddressSelected;

  const AddressSearchScreen({required this.onAddressSelected, super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  // Windows용 컨트롤러
  late final WebviewController _windowsController;
  bool _isWindowsWebViewInitialized = false;

  // 모바일용 컨트롤러
  late final WebViewController _mobileController;
  bool _isMobileWebViewInitialized = false;

  @override
  void initState() {
    super.initState();
    // Dio 설정을 먼저 초기화한 후 웹뷰 초기화 진행
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await setupDio();
      if (Platform.isWindows) {
        _windowsController = WebviewController();
        _initWindowsWebView();
      } else if (Platform.isAndroid || Platform.isIOS) {
        _initMobileWebView();
      }
    } catch (e) {
      print("Dio 설정 실패: $e");
    }
  }

  // Windows에서 HTML 로드 및 메시지 수신
  Future<void> _initWindowsWebView() async {
    try {
      await _windowsController.initialize();
      print("✅ Windows WebView 초기화 완료");

      _windowsController.webMessage.listen((message) async {
        print("📌 Windows WebView에서 받은 데이터: $message");
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          final address = data['address'];
          widget.onAddressSelected(address);
          Navigator.pop(context);
        } catch (e) {
          print('주소 파싱 오류: $e');
        }
      });

      // dio_setup.dart에 설정된 서버 baseUrl을 이용하여 HTML 파일 URL 구성
      String url = '${dio.options.baseUrl}/kakao_postcode.html';
      print("Windows에서 로드할 URL: $url");
      await _windowsController.loadUrl(url);

      setState(() {
        _isWindowsWebViewInitialized = true;
      });
    } catch (e) {
      print("❌ Windows WebView 초기화 실패: $e");
    }
  }

  // 모바일(Android/iOS)에서 HTML 로드 및 메시지 수신
  Future<void> _initMobileWebView() async {
    try {
      _mobileController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (JavaScriptMessage message) {
            print("📌 Mobile WebView에서 받은 메시지: ${message.message}");
            try {
              final Map<String, dynamic> data = jsonDecode(message.message);
              final address = data['address'];
              widget.onAddressSelected(address);
              Navigator.pop(context);
            } catch (e) {
              print('주소 파싱 오류 (모바일): $e');
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) {
              print("✅ Mobile WebView 페이지 로드 완료: $url");
            },
            onWebResourceError: (error) {
              print("❌ Mobile WebView 에러: $error");
            },
          ),
        );

      // 서버 URL로 HTML 파일 로드
      String url = '${dio.options.baseUrl}/kakao_postcode.html';
      print("모바일에서 로드할 URL: $url");
      // 반드시 await loadRequest로 처리하여 로드 완료를 기다립니다.
      await _mobileController.loadRequest(Uri.parse(url));

      setState(() {
        _isMobileWebViewInitialized = true;
      });
    } catch (e) {
      print("❌ Mobile WebView 초기화 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: Platform.isWindows
          ? (_isWindowsWebViewInitialized
              ? SizedBox.expand(child: Webview(_windowsController))
              : const Center(child: CircularProgressIndicator()))
          : (_isMobileWebViewInitialized
              ? WebViewWidget(controller: _mobileController)
              : const Center(child: CircularProgressIndicator())),
    );
  }
}
