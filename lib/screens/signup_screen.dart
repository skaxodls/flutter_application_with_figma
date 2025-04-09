import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

// Windows 전용 웹뷰 패키지 (별칭으로 불러오기)
import 'package:webview_windows/webview_windows.dart' as win;
// 모바일(Android/iOS) 전용 웹뷰 패키지 (최신 API 사용)
import 'package:webview_flutter/webview_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _regionNameController = TextEditingController();
  final TextEditingController _detailedAddressController =
      TextEditingController();

  Future<void> _openAddressSearch(BuildContext context) async {
    if (Platform.isWindows) {
      // Windows 환경: webview_windows 사용
      final controller = win.WebviewController();
      await controller.initialize();

      controller.webMessage.listen((message) async {
        print("📌 Windows WebView에서 받은 데이터: $message");
        try {
          final data = jsonDecode(message);
          final regionName = data['extra'] ?? ''; // 시/구/동
          final detailedAddress = data['address'] ?? ''; // 상세 주소
          if (regionName.isNotEmpty && detailedAddress.isNotEmpty) {
            setState(() {
              _regionNameController.text = regionName;
              _detailedAddressController.text = detailedAddress;
            });
            Navigator.pop(context);
          }
        } catch (e) {
          print('주소 파싱 실패: $e');
        }
      });

      await controller.loadUrl('${dio.options.baseUrl}/kakao_postcode.html');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("주소 검색")),
            body: win.Webview(controller),
          ),
        ),
      );
    } else {
      // 안드로이드/IOS 환경: webview_flutter 사용
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (JavaScriptMessage message) {
            print("📌 Mobile WebView에서 받은 메시지: ${message.message}");
            try {
              final data = jsonDecode(message.message);
              final regionName = data['extra'] ?? ''; // 시/구/동
              final detailedAddress = data['address'] ?? ''; // 상세 주소
              if (regionName.isNotEmpty && detailedAddress.isNotEmpty) {
                setState(() {
                  _regionNameController.text = regionName;
                  _detailedAddressController.text = detailedAddress;
                });
                Navigator.pop(context);
              }
            } catch (e) {
              print('주소 파싱 실패 (모바일): $e');
            }
          },
        );

      await controller
          .loadRequest(Uri.parse('${dio.options.baseUrl}/kakao_postcode.html'));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("주소 검색")),
            body: WebViewWidget(controller: controller),
          ),
        ),
      );
    }
  }

  Future<void> _submitSignUp() async {
    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();
    final name = _usernameController.text.trim();
    final regionName = _regionNameController.text.trim();
    final detailedAddress = _detailedAddressController.text.trim();

    if (id.isEmpty ||
        pw.isEmpty ||
        name.isEmpty ||
        regionName.isEmpty ||
        detailedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 입력해주세요.")),
      );
      return;
    }

    try {
      // dio 인스턴스를 이용하여 회원가입 API 호출 (baseUrl은 dio_setup.dart에서 설정됨)
      final response = await dio.post(
        '/api/register',
        data: {
          'id': id,
          'password': pw,
          'username': name,
          'region_name': regionName,
          'detailed_address': detailedAddress,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 완료! 🎉")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입 실패: ${response.data}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildInputField("아이디", _idController, false),
              const SizedBox(height: 15),
              _buildInputField("비밀번호", _passwordController, true),
              const SizedBox(height: 15),
              _buildInputField("사용자명", _usernameController, false),
              const SizedBox(height: 15),
              _buildLocationPickerField(context),
              const SizedBox(height: 30),
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Fish Go',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Image.asset("assets/icons/fish_icon1.png", width: 40, height: 40),
      ],
    );
  }

  Widget _buildInputField(
      String hint, TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildLocationPickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _openAddressSearch(context),
            child: AbsorbPointer(
              child: TextField(
                controller: _regionNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  hintText: "거주 지역 (시/구/동)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _detailedAddressController,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              hintText: "상세 주소 (도로명 등)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _submitSignUp,
      child: Container(
        width: 180,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
