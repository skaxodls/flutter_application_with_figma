import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/login_screen.dart';
import 'package:flutter_application_with_figma/screens/signup_screen.dart';
import 'home_screen.dart';
import 'community_screen.dart';
import 'market_price_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 10),
            _buildLoginSection(),
            SizedBox(height: 15),
            _buildServiceSection(context), // 🔥 로그인 & 회원가입 버튼 추가됨!
            SizedBox(height: 15),
            _buildServiceSectionIcons(context), // 🔥 context 추가
            SizedBox(height: 15),
            _buildMyTransactions(context), // 🔥 context 추가
          ],
        ),
      ),
    );
  }

  // 🔹 헤더 (Fish Go + 로고)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Text(
            'Fish Go',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Rubik One',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 8),
          Image.asset("assets/icons/fish_icon1.png", width: 30, height: 30),
        ],
      ),
    );
  }

  // 🔹 로그인 섹션
  Widget _buildLoginSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle, size: 50, color: Colors.black),
          SizedBox(width: 10),
          Text(
            '로그인 하세요',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          Spacer(),
          Icon(Icons.settings, size: 30, color: Colors.black),
        ],
      ),
    );
  }

  // 🔹 로그인 & 회원가입 버튼
  Widget _buildServiceSection(BuildContext context) {
    // 🔥 context 추가
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen()), // 🔥 로그인 화면 이동 추가
                );
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Color(0xFFA6C5FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  '로그인',
                  style: TextStyle(color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpScreen()), // 🔥 회원가입 화면 이동 추가
                );
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  '회원가입',
                  style: TextStyle(color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // 🔹 서비스 (내 낚시 포인트, 어류 도감, 커뮤니티, 싯가)
  Widget _buildServiceSectionIcons(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _serviceIcon("내 낚시 포인트", Icons.place, context),
              _serviceIcon("어류 도감", Icons.book, context),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _communityIcon(context), // 🔥 커뮤니티 클릭 시 이동
              _serviceIcon("싯가", Icons.attach_money, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceIcon(String title, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () => _showLoginPopup(context), // 🔥 팝업 표시
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }


  // 🔥 "커뮤니티"는 팝업 없이 바로 이동
  Widget _communityIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommunityScreen()),
        );
      },
      child: Column(
        children: [
          Icon(Icons.people, color: Colors.white, size: 40),
          SizedBox(height: 5),
          Text(
            "커뮤니티",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 🔹 나의 거래 목록 (찜한 목록, 거래 일정 관리, 판매 내역, 구매 내역, 내 활동구역 글 모아보기)
  Widget _buildMyTransactions(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _transactionItem("찜한 목록", Icons.favorite, context),
          _transactionItem("거래 일정 관리", Icons.calendar_today, context),
          _transactionItem("판매 내역", Icons.list, context),
          _transactionItem("구매 내역", Icons.shopping_cart, context),
          _transactionItem("내 활동구역 글 모아보기", Icons.menu, context),
        ],
      ),
    );
  }

  Widget _transactionItem(String title, IconData icon, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: () => _showLoginPopup(context), // 🔥 팝업 표시
    );
  }

  // 🔹 하단 네비게이션 바 (홈 화면과 동일한 네비게이션 기능 추가!)
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      currentIndex: 4,
      // ✅ "마이페이지" 탭 활성화
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CommunityScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MarketPriceScreen()),
          );
        }
      },
      items: [
        _bottomNavItem(Icons.home, "홈"),
        _bottomNavItem(Icons.chat, "커뮤니티"),
        _bottomNavItem(Icons.place, "내 포인트"),
        _bottomNavItem(Icons.attach_money, "싯가"),
        _bottomNavItem(Icons.person, "마이페이지"),
      ],
    );
  }

  BottomNavigationBarItem _bottomNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  // 🔥 "로그인하세요" 팝업 함수
  void _showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("로그인이 필요합니다"),
          content: Text("이 기능을 사용하려면 로그인해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen()), // 🔥 로그인 화면 이동 추가
                );
              },
              child: Text("로그인"),
            ),
          ],
        );
      },
    );
  }
}
