import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

// Windows 전용 웹뷰 패키지
import 'package:webview_windows/webview_windows.dart';
// 모바일(Android/iOS) 전용 웹뷰 패키지 (최신 API 사용)
import 'package:webview_flutter/webview_flutter.dart';

class KakaoMapScreen2 extends StatefulWidget {
  final String? initialAddress; // 상세주소만 전달받음 (내 포인트 목록 클릭 시)
  const KakaoMapScreen2({Key? key, this.initialAddress}) : super(key: key);

  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen2> {
  // Windows용 웹뷰 컨트롤러
  late final WebviewController _windowsController;
  bool _isWindowsWebViewInitialized = false;

  // 모바일(Android/iOS)용 웹뷰 컨트롤러 (webview_flutter 최신 API)
  late final WebViewController _mobileController;
  bool _isMobileWebViewInitialized = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows) {
      _windowsController = WebviewController();
      _initWindowsWebView();
    } else if (Platform.isAndroid || Platform.isIOS) {
      _initMobileWebView();
    }
  }

  // Windows 전용 웹뷰 초기화 함수
  Future<void> _initWindowsWebView() async {
    try {
      await _windowsController.initialize();
      print("✅ Windows WebView 초기화 완료");

      // Windows 웹뷰: 메시지 수신 리스너
      _windowsController.webMessage.listen((message) async {
        print("📌 Windows WebView에서 받은 데이터: $message");
        try {
          final Map<String, dynamic> addressData = jsonDecode(message);

          // addressName이 "포인트 위치"이면 사용자에게 지역 이름 입력 요청
          if (addressData['addressName'] == '포인트 위치') {
            String? regionName = await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                final TextEditingController controller =
                    TextEditingController();
                return AlertDialog(
                  title: const Text("지역 이름 입력"),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "지역 이름을 입력하세요",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text("취소"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text),
                      child: const Text("확인"),
                    ),
                  ],
                );
              },
            );
            if (regionName != null && regionName.isNotEmpty) {
              addressData['addressName'] = regionName;
            }
          }

          final String formattedAddress =
              "${addressData['addressName']} (${addressData['detailedAddress']})";
          print("📌 변환된 주소: $formattedAddress");

          // Windows에서 모달 BottomSheet로 주소 확인 요청
          bool? confirmed = await showModalBottomSheet<bool>(
            context: context,
            barrierColor: Colors.transparent,
            isDismissible: false,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Wrap(
                  children: [
                    Center(
                      child: Text(
                        "지역 추가",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "선택한 지역을 추가하시겠습니까?\n\n$formattedAddress",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("아니요"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("예"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
          if (confirmed == true) {
            Navigator.pop(context, formattedAddress);
          } else {
            print("사용자가 추가를 취소했습니다.");
          }
        } catch (e) {
          print("❌ Windows WebView JSON 파싱 오류: $e");
        }
      });

      // URL 생성: initialAddress가 있으면 쿼리 파라미터로 추가
      String url = '${dio.options.baseUrl}/kakao_map.html';
      if (widget.initialAddress != null) {
        final encoded = Uri.encodeComponent(widget.initialAddress!);
        url += '?initialAddress=$encoded';
      }
      await _windowsController.loadUrl(url);

      setState(() {
        _isWindowsWebViewInitialized = true;
      });
    } catch (e) {
      print("❌ Windows WebView 초기화 실패: $e");
    }
  }

  // 모바일(Android/iOS)용 웹뷰 초기화 함수 (최신 webview_flutter API 사용)
  Future<void> _initMobileWebView() async {
    _mobileController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // 모바일에서 HTML로부터 메시지를 받기 위한 JavaScriptChannel 등록
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print("📌 Mobile WebView에서 받은 메시지: ${message.message}");
          try {
            final Map<String, dynamic> addressData =
                jsonDecode(message.message);
            _showMobileAddressConfirmation(addressData);
          } catch (e) {
            print("❌ Mobile WebView JSON 파싱 오류: $e");
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

    String url = '${dio.options.baseUrl}/kakao_map.html';
    if (widget.initialAddress != null) {
      final encoded = Uri.encodeComponent(widget.initialAddress!);
      url += '?initialAddress=$encoded';
    }
    // 페이지 요청 로드
    _mobileController.loadRequest(Uri.parse(url));

    setState(() {
      _isMobileWebViewInitialized = true;
    });
  }

  // 모바일에서 메시지 수신 시, 하단 모달 BottomSheet를 띄워 주소 확인하는 함수
  void _showMobileAddressConfirmation(Map<String, dynamic> addressData) async {
    final String formattedAddress =
        "${addressData['addressName']} (${addressData['detailedAddress']})";
    bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      barrierColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Wrap(
            children: [
              Center(
                child: Text(
                  "지역 추가",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "선택한 지역을 추가하시겠습니까?\n\n$formattedAddress",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("아니요"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("예"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (confirmed == true) {
      Navigator.pop(context, formattedAddress);
    } else {
      print("사용자가 추가를 취소했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "거래 장소",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Platform.isWindows
          ? (_isWindowsWebViewInitialized
              ? SizedBox.expand(child: Webview(_windowsController))
              : const Center(child: CircularProgressIndicator()))
          : _isMobileWebViewInitialized
              ? WebViewWidget(controller: _mobileController)
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
