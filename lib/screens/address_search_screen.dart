import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:convert';
import 'dart:io';

class AddressSearchScreen extends StatefulWidget {
  final Function(String) onAddressSelected;

  const AddressSearchScreen({required this.onAddressSelected, super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final controller = WebviewController();

  @override
  void initState() {
    super.initState();
    initWebView();
  }

  Future<void> initWebView() async {
    await controller.initialize();

    controller.webMessage.listen((message) {
      try {
        final data = jsonDecode(message);
        final address = data['address'];
        widget.onAddressSelected(address);
        Navigator.pop(context); // 주소 전달하고 화면 닫기
      } catch (e) {
        print('주소 파싱 오류: $e');
      }
    });

    final htmlPath = 'flask/templates/kakao_postcode.html';
    final fileUri = Uri.file('${Directory.current.path}/$htmlPath').toString();

    await controller.loadUrl(fileUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주소 검색')),
      body: FutureBuilder(
        future: controller.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Webview(controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
