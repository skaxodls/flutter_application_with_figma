import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/dio_setup.dart'; // Dio 인스턴스 설정 파일
import 'package:flutter_application_with_figma/screens/write_screen.dart'; // 글쓰기 화면
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart'; // ContentReaderScreen 페이지
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/screens/mypage_screen.dart';
import 'package:flutter_application_with_figma/screens/community_screen.dart';
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';
import 'package:flutter_application_with_figma/screens/market_price_screen.dart';
import 'home_screen.dart';

class LocalPostScreen extends StatefulWidget {
  const LocalPostScreen({Key? key}) : super(key: key);

  @override
  State<LocalPostScreen> createState() => _LocalPostScreenState();
}

class _LocalPostScreenState extends State<LocalPostScreen> {
  // 백엔드 API에서 받아온 게시글 리스트와 사용자의 지역 정보
  List<dynamic> posts = [];
  String userRegion = ""; // classify_address 반환값으로 채워짐

  // status 값에 따른 색상 반환 함수
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
  void initState() {
    super.initState();
    fetchPostsByRegion();
  }

  Future<void> fetchPostsByRegion() async {
    try {
      final response = await dio.get("/api/posts_by_region");
      if (response.statusCode == 200) {
        setState(() {
          // API가 반환한 JSON 객체의 형식:
          // { "user_region": "xxx", "posts": [ ... ] }
          userRegion = response.data["user_region"] ?? "";
          posts = response.data["posts"] ?? [];
        });
      } else {
        print("Error fetching posts: ${response.statusCode}");
      }
    } catch (e) {
      print("게시글 로드 실패: $e");
    }
  }

  Widget buildPostImage(String imageUrl) {
    // 기본 이미지 경로는 Flutter Asset 이미지로 처리
    if (imageUrl == "assets/icons/fish_icon2.png") {
      return Image.asset(
        imageUrl,
        height: 95,
        width: 95,
        fit: BoxFit.cover,
      );
    }
    // imageUrl이 네트워크 URL이 아니면, 서버의 기본 URL을 추가합니다.
    if (!imageUrl.startsWith("http")) {
      imageUrl = "${dio.options.baseUrl}" + imageUrl;
    }
    return Image.network(
      imageUrl,
      height: 95,
      width: 95,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar 제목은 사용자의 region (API 반환값)을 사용
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF3F7EFF),
        title: Text(
          userRegion.isNotEmpty ? userRegion : "Loading...",
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          posts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 60, top: 10),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    // 게시글 이미지: images 리스트가 있으면 첫 번째 이미지의 image_url, 없으면 기본 이미지 경로 사용
                    String imageUrl = "assets/icons/fish_icon2.png";
                    if (post["images"] != null &&
                        post["images"] is List &&
                        post["images"].isNotEmpty) {
                      // 이미지 객체의 key는 image_url로 가정
                      imageUrl = post["images"][0]["image_url"] ?? imageUrl;
                    }
                    return GestureDetector(
                      onTap: () async {
                        // 게시글 클릭 시, post의 상세 정보를 받아와 상세 페이지로 이동
                        try {
                          final postId = post["post_id"];
                          final response = await dio.get("/api/posts/$postId");
                          if (response.statusCode == 200) {
                            final jsonData = response.data;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContentReaderScreen(
                                  image: jsonData['image_url'],
                                  title: jsonData['title'],
                                  location: jsonData['location'],
                                  price: jsonData['price'],
                                  comments: jsonData['comment_count'],
                                  likes: jsonData['like_count'],
                                  tagColor: Color(int.parse(jsonData['tagColor']
                                      .replaceFirst('#', '0xff'))),
                                  username: jsonData['username'],
                                  userRegion: jsonData['userRegion'],
                                  postId: jsonData['post_id'],
                                  postUid: jsonData['uid'],
                                  currentUserUid: jsonData['currentUserUid'],
                                  content: jsonData['content'],
                                  createdAt: jsonData['created_at'],
                                  status: jsonData['status'],
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "게시글 상세 정보 로드 실패: ${response.statusCode}")),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("오류 발생: $e")),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 15),
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
                              child: buildPostImage(imageUrl),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 제목과 post_status 태그 Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          post["title"] ?? "제목 없음",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                      if (post["post_status"] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                                post["post_status"]),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            post["post_status"],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // region_name 표시 (게시글의 지역명)
                                  Text(
                                    post["region_name"] ?? "",
                                    style: const TextStyle(
                                        color: Color(0xFF999999), fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  // 가격 및 댓글/좋아요 정보
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${post["price"]}원",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.comment,
                                              size: 16,
                                              color: Color(0xFF999999)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${post["comment_count"]}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.favorite,
                                              size: 16,
                                              color: Color(0xFF999999)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${post["like_count"]}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
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
                  },
                ),
          // 하단 오른쪽 "글쓰기" 버튼
        ],
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
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 4, // 원하는 인덱스로 설정
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
            // ✅ 마이페이지 클릭 시 세션 상태 확인 후 분기
            try {
              final response = await dio.get('/api/check_session');
              final loggedIn = response.statusCode == 200 &&
                  response.data['logged_in'] == true;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => loggedIn
                      ? const MyPageLoginScreen()
                      : const MyPageScreen(),
                ),
              );
            } catch (e) {
              // 오류 발생 시 기본 마이페이지로 이동
              Navigator.push(
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
