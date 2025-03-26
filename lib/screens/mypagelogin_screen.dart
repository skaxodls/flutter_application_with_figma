import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'community_screen.dart';
import 'market_price_screen.dart';
import 'mypage_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

class MyPageLoginScreen extends StatefulWidget {
  const MyPageLoginScreen({super.key});

  @override
  State<MyPageLoginScreen> createState() => _MyPageLoginScreenState();
}

class _MyPageLoginScreenState extends State<MyPageLoginScreen> {
  String username = '';
  String region = '';
  int uid = 0;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await dio.get('/api/user_profile');
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          username = data['username'];
          region = data['region'];
          uid = data['uid'];
        });
      }
    } catch (e) {
      print('사용자 정보 가져오기 실패: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final response = await dio.post('/api/logout');
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyPageScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그아웃 실패")),
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
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            const Text(
              "Fish Go",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 5),
            Image.asset('assets/icons/fish_icon1.png', height: 24),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 10),
            _buildServiceSection(),
            const SizedBox(height: 10),
            _buildMyTransactions(),
            const SizedBox(height: 10),
            _buildMyPosts(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
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
              MaterialPageRoute(
                  builder: (context) => const MarketPriceScreen()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyPageLoginScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "커뮤니티"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "내 포인트"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "싯가"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이페이지"),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage("assets/icons/profile_icon.png"),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                region,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                "UID $uid",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, size: 30, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _serviceIcon("내 낚시 포인트", Icons.place),
              _serviceIcon("어류 도감", Icons.book),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _serviceIcon("커뮤니티", Icons.people),
              _serviceIcon("싯가", Icons.attach_money),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceIcon(String title, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 40),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMyTransactions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFA6C5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _transactionItem("찜한 목록", Icons.favorite),
          _transactionItem("거래 일정 관리", Icons.calendar_today),
          _transactionItem("판매 내역", Icons.list),
          _transactionItem("구매 내역", Icons.shopping_cart),
          _transactionItem("내 활동구역 글 모아보기", Icons.menu),
        ],
      ),
    );
  }

  Widget _transactionItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: () {},
    );
  }

  Widget _buildMyPosts() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("내가 작성한 글",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("더보기 >", style: TextStyle(fontSize: 12, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Image.asset("assets/images/fish_image1.png",
                width: 60, height: 60),
            title: const Text("농어 팝니다",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text("포항시 이동 · 20분 전\n20,000원"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.comment, size: 16, color: Colors.black54),
                SizedBox(width: 4),
                Text("3"),
                SizedBox(width: 12),
                Icon(Icons.favorite, size: 16, color: Colors.black54),
                SizedBox(width: 4),
                Text("3"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
