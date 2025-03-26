import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/write_screen.dart';
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'market_price_screen.dart';
import 'mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart'; // dio 인스턴스 import

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    try {
      final response = await dio.get('/api/check_session');
      if (response.statusCode == 200 && response.data['logged_in'] == true) {
        setState(() {
          isLoggedIn = true;
        });
      }
    } catch (e) {
      print('세션 확인 실패: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _CommunityPost(
              image: 'assets/images/fish_image1.png',
              title: "농어 팝니다",
              location: "포항시 이동 · 20분 전",
              price: "20,000원",
              comments: 3,
              likes: 3,
            ),
            _CommunityPost(
              image: 'assets/images/fish_image2.png',
              title: "갓잡은 감성돔 팝니다",
              location: "남해군 남면 · 1시간 전",
              price: "20,000원",
              comments: 2,
              likes: 5,
              tag: "예약중",
              tagColor: Color(0xFF4A68EA),
            ),
            _CommunityPost(
              image: 'assets/images/fish_image3.png',
              title: "방어팝니다",
              location: "진해항 부근 · 9시간 전",
              price: "25,000원",
              comments: 1,
              likes: 2,
              tag: "거래완료",
              tagColor: Colors.black,
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WriteScreen()),
          );
        },
        backgroundColor: const Color(0xFFD9D9D9),
        icon: Image.asset('assets/icons/pencil_icon.png', height: 24),
        label: const Text("글쓰기", style: TextStyle(color: Colors.black)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) async {
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
            try {
              final response = await dio.get('/api/check_session');
              final loggedIn = response.statusCode == 200 &&
                  response.data['logged_in'] == true;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => loggedIn
                      ? const MyPageLoginScreen()
                      : const MyPageScreen(),
                ),
              );
            } catch (e) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyPageScreen()),
              );
            }
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
}

class _CommunityPost extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String price;
  final int comments;
  final int likes;
  final String? tag;
  final Color? tagColor;

  const _CommunityPost({
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.comments,
    required this.likes,
    this.tag,
    this.tagColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentReaderScreen(
              image: image,
              title: title,
              location: location,
              price: price,
              comments: comments,
              likes: likes,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child:
                  Image.asset(image, height: 95, width: 95, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      if (tag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF999999)),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                            color: Color(0xFF999999), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              size: 16, color: Color(0xFF999999)),
                          const SizedBox(width: 4),
                          Text("$comments",
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.favorite,
                              size: 16, color: Color(0xFF999999)),
                          const SizedBox(width: 4),
                          Text("$likes", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
