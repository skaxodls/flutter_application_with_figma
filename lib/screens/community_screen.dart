import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/write_screen.dart';
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'market_price_screen.dart';
import 'mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isLoggedIn = false;
  int currentUserUid = -1;
  List<dynamic> posts = []; // 🔹 게시글 리스트

  @override
  void initState() {
    super.initState();
    checkSession();
    fetchPosts(); // 🔹 게시글 API 호출
  }

  Future<void> checkSession() async {
    try {
      final response = await dio.get('/api/check_session');
      if (response.statusCode == 200 && response.data['logged_in'] == true) {
        setState(() {
          isLoggedIn = true;
          currentUserUid = response.data['uid'];
        });
      }
    } catch (e) {
      print('세션 확인 실패: $e');
    }
  }

  Future<void> fetchPosts() async {
    try {
      final response = await dio.get('/api/posts');
      if (response.statusCode == 200) {
        setState(() {
          posts = response.data;
        });
      }
    } catch (e) {
      print("게시글 로드 실패: $e");
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case '예약중':
        return const Color(0xFF4A68EA);
      case '거래완료':
        return Colors.black;
      default:
        return Colors.grey;
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
      body: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _CommunityPost(
                  image: post['image'] ?? 'assets/images/fish_image1.png',
                  title: post['title'] ?? '제목 없음',
                  location: post['location'] ?? '위치 없음',
                  price: post['price'] ?? 0,
                  comments: post['comment_count'] ?? 0,
                  likes: post['like_count'] ?? 0,
                  tag: post['status'],
                  tagColor: _statusColor(post['status']),
                  username: post['username'] ?? '사용자',
                  userRegion: post['location'] ?? '',
                  postUid: post['uid'],
                  currentUserUid: currentUserUid,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WriteScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("로그인이 필요합니다.")),
            );
          }
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
  final int price;
  final int comments;
  final int likes;
  final String? tag;
  final Color? tagColor;
  final String username;
  final String userRegion;
  final int postUid;
  final int currentUserUid;

  const _CommunityPost({
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.comments,
    required this.likes,
    this.tag,
    this.tagColor,
    required this.username,
    required this.userRegion,
    required this.postUid,
    required this.currentUserUid,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

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
              username: username,
              userRegion: userRegion,
              postUid: postUid,
              currentUserUid: currentUserUid,
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
                        '${formatter.format(price)}원',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
