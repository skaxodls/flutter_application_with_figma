import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/screens/signup_screen.dart';
import 'package:flutter_application_with_figma/screens/mypage_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final response = await dio.get('/api/check_session');
      if (response.statusCode == 200 && response.data['logged_in'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyPageLoginScreen(),
          ),
        );
      }
    } catch (e) {
      print('세션 확인 실패: $e');
    }
  }

  Future<void> _handleLogin(BuildContext context) async {
    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("아이디와 비밀번호를 모두 입력해주세요.")),
      );
      return;
    }

    try {
      final response = await dio.post('/api/login', data: {
        'id': id,
        'password': pw,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 성공! 🎉")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyPageLoginScreen()),
        );
      } else if (response.statusCode == 401) {
        // 🔔 로그인 실패 - 아이디 또는 비밀번호 불일치
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("아이디 또는 비밀번호를 다시 확인하세요.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: ${response.data['error']}")),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyPageScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            _buildHeader(),
            const SizedBox(height: 30),
            _buildInputField("아이디", _idController, false),
            const SizedBox(height: 15),
            _buildInputField("비밀번호", _passwordController, true),
            const SizedBox(height: 30),
            _buildLoginButton(context),
            const SizedBox(height: 15),
            _buildSignUpButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Fish Go',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Rubik One',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset("assets/icons/fish_icon1.png", width: 40, height: 40),
          ],
        ),
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

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleLogin(context),
      child: Container(
        width: 180,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF4A68EA),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: const Text(
          '로그인',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      },
      child: const Text(
        '회원이 아니신가요? 회원가입',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
