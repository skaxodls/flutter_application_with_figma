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
        child: SingleChildScrollView(
          // 스크롤 기능 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildLoginSection(),
              const SizedBox(height: 15),
              _buildServiceSection(context), // 로그인 & 회원가입 버튼
              const SizedBox(height: 15),
              _buildServiceSectionIcons(context), // 서비스 아이콘 영역 (이미지 적용)
              const SizedBox(height: 15),
              _buildMyTransactions(context), // 나의 거래 영역 (타이틀 & 이미지 아이콘)
            ],
          ),
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
          const Text(
            "Fish Go",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset("assets/icons/fish_icon1.png", width: 30, height: 30),
        ],
      ),
    );
  }

  // 🔹 로그인 섹션
  Widget _buildLoginSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle, size: 50, color: Colors.black),
          const SizedBox(width: 10),
          Text(
            '로그인 하세요',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          // 설정 아이콘 → 이미지로 대체
          Image.asset(
            "assets/mypage_images/setting.png",
            width: 30,
            height: 30,
          ),
        ],
      ),
    );
  }

  // 🔹 로그인 & 회원가입 버튼
  Widget _buildServiceSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFA6C5FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '로그인',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Container(
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
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 서비스 아이콘 섹션 (상단에 "서비스" 타이틀 추가)
  Widget _buildServiceSectionIcons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "서비스",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _serviceImageIcon(
                  "내 낚시 포인트", "assets/mypage_images/map_icon2.png", context),
              _serviceImageIcon(
                  "어류 도감", "assets/mypage_images/book_icon2.png", context),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _serviceImageIcon(
                  "커뮤니티", "assets/mypage_images/community.png", context,
                  goToCommunity: true),
              _serviceImageIcon("싯가", "assets/mypage_images/coin.png", context),
            ],
          ),
        ],
      ),
    );
  }

  // 이미지와 텍스트가 가로로 정렬된 서비스 아이콘 위젯
  Widget _serviceImageIcon(String title, String imagePath, BuildContext context,
      {bool goToCommunity = false}) {
    return GestureDetector(
      onTap: () {
        if (goToCommunity) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunityScreen()),
          );
        } else {
          _showLoginPopup(context);
        }
      },
      child: SizedBox(
        width: 130, // 아이콘 정렬 통일을 위한 고정 너비
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: 30, height: 30),
            const SizedBox(width: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 나의 거래 섹션 (상단에 "나의 거래" 타이틀 추가 및 이미지 아이콘 적용)
  Widget _buildMyTransactions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "나의 거래",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          _transactionItem("찜한 목록", Icons.favorite, context),
          _transactionItem("거래 일정 관리", Icons.calendar_today, context),
          _transactionItem("판매 내역", null, context,
              imagePath: "assets/mypage_images/bill.png"),
          _transactionItem("구매 내역", null, context,
              imagePath: "assets/mypage_images/shopping-basket.png"),
          _transactionItem("내 활동구역 글 모아보기", null, context,
              imagePath: "assets/mypage_images/post_icon.png"),
        ],
      ),
    );
  }

  // 거래 항목 리스트 (아이콘 대신 이미지 적용)
  Widget _transactionItem(String title, IconData? icon, BuildContext context,
      {String? imagePath}) {
    return ListTile(
      leading: imagePath != null
          ? Image.asset(imagePath, width: 24, height: 24)
          : Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: () => _showLoginPopup(context),
    );
  }

  // 🔹 하단 네비게이션 바 (홈, 커뮤니티, 내 포인트, 싯가, 마이페이지)
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      currentIndex: 4,
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

  // 🔥 로그인 필요 팝업 함수
  void _showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("로그인이 필요합니다"),
          content: const Text("이 기능을 사용하려면 로그인해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("로그인"),
            ),
          ],
        );
      },
    );
  }
}
