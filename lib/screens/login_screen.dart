import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/screens/signup_screen.dart';
import 'package:flutter_application_with_figma/screens/mypage_screen.dart';
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MyPageScreen()), // ✅ 뒤로가기 → 마이페이지 이동
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),

            // 헤더 (Fish Go 로고 및 타이틀)
            _buildHeader(),

            SizedBox(height: 30),

            // 로그인 입력 필드
            _buildInputField("아이디", _idController, false),
            SizedBox(height: 15),
            _buildInputField("비밀번호", _passwordController, true),

            SizedBox(height: 30),

            // 로그인 버튼
            _buildLoginButton(context),

            SizedBox(height: 15),

            // 회원가입 이동 버튼
            _buildSignUpButton(context),
          ],
        ),
      ),
    );
  }

  // 🔹 헤더 (Fish Go 로고 및 타이틀)
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Fish Go',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Rubik One',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Image.asset("assets/icons/fish_icon1.png", width: 40, height: 40),
          ],
        ),
        SizedBox(height: 20),
        Text(
          '로그인 하세요',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // 🔹 입력 필드 (아이디 & 비밀번호)
  Widget _buildInputField(
      String hint, TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFD9D9D9),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  // 🔹 로그인 버튼
  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   print("로그인 시도: ${_idController.text}, ${_passwordController.text}");
      // },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPageLoginScreen()), //
        );
      },
      child: Container(
        width: 180,
        height: 45,
        decoration: BoxDecoration(
          color: Color(0xFF4A68EA),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
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

  // 🔹 회원가입 이동 버튼
  Widget _buildSignUpButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SignUpScreen()), // 🔥 회원가입 화면 이동 추가
        );
      },
      child: Text(
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
