import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';

class KakaoMapScreen2 extends StatefulWidget {
  final String? initialAddress; // 상세주소만 전달받음 (내 포인트 목록 클릭 시)
  const KakaoMapScreen2({Key? key, this.initialAddress}) : super(key: key);

  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen2> {
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

      // WebView에서 메시지 수신 (주소 선택 후 처리)
      _controller.webMessage.listen((message) async {
        print("📌 WebView에서 받은 데이터: $message");
        try {
          final Map<String, dynamic> addressData = jsonDecode(message);

          // 만약 addressName이 "포인트 위치"라면 사용자에게 지역 이름 입력을 요청합니다.
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
            // 만약 사용자가 유효한 값을 입력하면 업데이트, 아니면 그대로 "포인트 위치"로 유지합니다.
            if (regionName != null && regionName.isNotEmpty) {
              addressData['addressName'] = regionName;
            }
          }

          final String formattedAddress =
              "${addressData['addressName']} (${addressData['detailedAddress']})";
          print("📌 변환된 주소: $formattedAddress");

          // 사용자에게 추가 여부를 묻는 BottomSheet 표시
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
          print("❌ JSON 파싱 오류: $e");
        }
      });

      // URL 생성: initialAddress가 있으면 쿼리 파라미터로 추가
      String url = 'http://127.0.0.1:5000/kakao_map.html';
      if (widget.initialAddress != null) {
        final encoded = Uri.encodeComponent(widget.initialAddress!);
        url += '?initialAddress=$encoded';
      }
      await _controller.loadUrl(url);

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
      body: _isWebViewInitialized
          ? SizedBox.expand(child: Webview(_controller))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
