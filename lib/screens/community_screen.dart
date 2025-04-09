import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/write_screen.dart';
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'market_price_screen.dart';
import 'mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isLoggedIn = false;
  int currentUserUid = -1;
  List<dynamic> posts = []; // 🔹 게시글 리스트
  bool showOnlySelling = false; // 🔸 판매중만 보기 스위치 상태

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
    final filteredPosts = showOnlySelling
        ? posts.where((post) => post['status'] == '판매중').toList()
        : posts;

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
      body: Column(
        children: [
          // 🔸 Switch UI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Switch(
                  value: showOnlySelling,
                  onChanged: (value) {
                    setState(() {
                      showOnlySelling = value;
                    });
                  },
                ),
                const Text(
                  '판매중만 보기',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // 🔸 게시글 리스트
          Expanded(
            child: filteredPosts.isEmpty
                ? const Center(child: Text('게시글이 없습니다.'))
                : ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      final imageUrl = post['image_url'] ?? '';
                      final hasImage = imageUrl.isNotEmpty &&
                          (imageUrl.startsWith('/static') ||
                              imageUrl.startsWith('http'));

                      return _CommunityPost(
                        image:
                            hasImage ? imageUrl : 'assets/images/noimage.png',
                        title: post['title'] ?? '제목 없음',
                        location: post['location'] ?? '위치 없음',
                        price: post['price'] ?? 0,
                        comments: post['comment_count'] ?? 0,
                        likes: post['like_count'] ?? 0,
                        tag: post['status'],
                        tagColor: _statusColor(post['status']),
                        username: post['username'] ?? '사용자',
                        userRegion: post['location'] ?? '',
                        postId: post['post_id'],
                        postUid: post['uid'],
                        currentUserUid: currentUserUid,
                        createdAt: post['created_at'] ?? '',
                        content: post['content'] ?? '',
                        status: post['status'] ?? '',
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (isLoggedIn) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WriteScreen()),
            );

            // 글 작성 후 돌아왔을 때 새로고침
            if (result == true) {
              fetchPosts(); // 글 목록 다시 불러오기
            }
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
          } else if (index == 2) {
            // 내 포인트 버튼 클릭 시
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPointScreen()),
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
  final int postId;
  final int postUid;
  final int currentUserUid;
  final String createdAt;
  final String content;
  final String status;

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
    required this.postId,
    required this.postUid,
    required this.currentUserUid,
    required this.createdAt,
    required this.content,
    required this.status,
    super.key,
  });

  String getTimeAgo(String createdAt) {
    final created = DateTime.tryParse(createdAt);
    if (created == null) return '';
    final now = DateTime.now();
    final difference = now.difference(created);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

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
              tagColor: tagColor,
              username: username,
              userRegion: userRegion,
              postId: postId,
              postUid: postUid,
              currentUserUid: currentUserUid,
              createdAt: createdAt,
              content: content,
              status: status,
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
              child: image.startsWith('/static') || image.startsWith('http')
                  ? Image.network(
                      'http://127.0.0.1:5000$image', // ← 서버 주소 추가
                      // 'http://10.0.2.2:5000$image',
                      // 'http://192.168.0.102:5000$image',
                      height: 95,
                      width: 95,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return const SizedBox(
                          width: 95,
                          height: 95,
                          child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 95,
                          height: 95,
                          child: Icon(Icons.broken_image, size: 40),
                        );
                      },
                    )
                  : Image.asset(
                      image.isNotEmpty ? image : 'assets/images/noimage.png',
                      height: 95,
                      width: 95,
                      fit: BoxFit.cover,
                    ),
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
                      const SizedBox(width: 10),
                      Text(
                        getTimeAgo(createdAt),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
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
