import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

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

            // 입력 필드 (아이디, 비밀번호, 사용자명, 거주 지역)
            _buildInputField("아이디", _idController, false),
            SizedBox(height: 15),
            _buildInputField("비밀번호", _passwordController, true),
            SizedBox(height: 15),
            _buildInputField("사용자명", _usernameController, false),
            SizedBox(height: 15),
            _buildInputField("거주 지역", _locationController, false),

            SizedBox(height: 30),

            // 회원가입 버튼
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
<<<<<<< HEAD
            Image.asset("assets/icons/fish_icon1.png", width: 40, height: 40),
=======
            Image.asset("assets/fish_icon.png", width: 40, height: 40),
>>>>>>> 392a4f26b44fc67d07037a350e9105bb2bbb77ac
          ],
        ),
      ],
    );
  }

  // 🔹 입력 필드 (아이디, 비밀번호, 사용자명, 거주 지역)
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

  // 🔹 회원가입 버튼
  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: () {
        print("회원가입 진행: ${_idController.text}, ${_passwordController.text}, ${_usernameController.text}, ${_locationController.text}");
      },
      child: Container(
        width: 180,
        height: 45,
        decoration: BoxDecoration(
          color: Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
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
