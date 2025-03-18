import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _openAddressSearch(BuildContext context) async {
    final controller = WebviewController();
    await controller.initialize();

    controller.webMessage.listen((message) {
      try {
        final data = jsonDecode(message);
        // final address = data['extra'] ?? ''; // ⚠️ 변경: extra 값을 사용 (시/구/동)
        final detailAddress = data['address'] ?? ''; // 상세주소
        if (detailAddress.isNotEmpty) {
          setState(() {
            _locationController.text = detailAddress;
          });
          Navigator.pop(context); // 닫기
        }
      } catch (e) {
        print('주소 파싱 실패: \$e');
      }
    });

    await controller.loadUrl('http://127.0.0.1:5000/kakao_postcode.html');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("주소 검색")),
          body: Webview(controller),
        ),
      ),
    );
  }

  Future<void> _submitSignUp() async {
    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();
    final name = _usernameController.text.trim();
    final location = _locationController.text.trim();

    if (id.isEmpty || pw.isEmpty || name.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 입력해주세요.")),
      );
      return;
    }

    final url = Uri.parse('http://127.0.0.1:5000/api/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'password': pw,
          'username': name,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 완료! 🎉")),
        );
        Navigator.pop(context); // 회원가입 후 뒤로 이동
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입 실패: \${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: \$e")),
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
      child: GestureDetector(
        onTap: () => _openAddressSearch(context),
        child: AbsorbPointer(
          child: TextField(
            controller: _locationController,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              hintText: "거주 지역 선택",
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
