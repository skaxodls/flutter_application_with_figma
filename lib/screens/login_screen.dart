import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            _buildLoginButton(),

            SizedBox(height: 15),

            // 회원가입 이동 버튼
            _buildSignUpButton(),
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
            Image.asset("assets/fish_icon.png", width: 40, height: 40),
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
  Widget _buildInputField(String hint, TextEditingController controller, bool isPassword) {
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
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () {
        print("로그인 시도: ${_idController.text}, ${_passwordController.text}");
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
  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: () {
        print("회원가입 화면으로 이동");
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
