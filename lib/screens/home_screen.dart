import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/TAC_screen.dart';
import 'package:flutter_application_with_figma/screens/weather_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
//screens
import 'package:flutter_application_with_figma/screens/community_screen.dart';
import 'package:flutter_application_with_figma/screens/select_photo_screen.dart';
import 'package:flutter_application_with_figma/screens/market_price_screen.dart';
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';
import 'package:flutter_application_with_figma/screens/mypage_screen.dart';
import 'package:flutter_application_with_figma/screens/pictorial_book_screen.dart';
import 'package:flutter_application_with_figma/screens/release_criteria_screen.dart';
import 'package:flutter_application_with_figma/screens/closed_season_screen.dart';
import 'package:flutter_application_with_figma/screens/fish_habitat_screen.dart';
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart';

//import 'package:http/http.dart' as http; // 🔧 HTTP 요청을 위해 추가
import 'package:flutter_application_with_figma/dio_setup.dart'; // 전역 dio 인스턴스 import

// 🔧 HomeScreen을 StatefulWidget으로 변경하여 상태 관리 가능하도록 수정
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String serverStatus = "Flask 연결 확인 중..."; // 🔧 서버 연결 상태 저장 변수 추가
  bool isLoggedIn = false;
  String tideInfo = "물때 정보를 가져오는 중..."; // 물때 정보 초기값

  @override
  void initState() {
    super.initState();
    checkSession();
    fetchTideInfo();
    fetchLatestPosts();
  }

  List<Map<String, dynamic>> latestPosts = [];

  Future<void> fetchLatestPosts() async {
    try {
      final response = await dio.get('/api/posts/latest');
      if (response.statusCode == 200) {
        setState(() {
          latestPosts = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      print('최신 게시글 불러오기 실패: $e');
    }
  }

  Future<void> fetchTideInfo() async {
    try {
      final response = await dio.get('/api/tide-info'); // Flask API 호출
      if (response.statusCode == 200) {
        setState(() {
          tideInfo = response.data['tide_info']; // Flask에서 JSON 형태로 보내준다고 가정
        });
      } else {
        setState(() {
          tideInfo = "물때 정보를 가져올 수 없습니다.";
        });
      }
    } catch (e) {
      setState(() {
        tideInfo = "물때 정보를 가져오는 중 오류 발생";
      });
    }
  }

  // ✅ Flask의 `/api/session` 엔드포인트 호출
  Future<void> fetchSessionInfo() async {
    try {
      final response = await dio.get('/api/session'); // dio 사용
      if (response.statusCode == 204) {
        print("✅ 세션 정보 요청 성공 (204 No Content)");
      } else {
        print("⚠️ 세션 정보 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API 요청 오류: $e");
    }
  }

  Future<void> checkSession() async {
    try {
      final response = await dio.get('/api/session'); // dio 사용
      if (response.statusCode == 200) {
        final data = response.data; // dio는 자동으로 JSON 파싱됨
        if (data['loggedIn'] == true) {
          setState(() {
            isLoggedIn = true;
          });
        }
      }
    } catch (e) {
      print("세션 확인 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // 전체 배경색
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
            Image.asset('assets/icons/fish_icon1.png',
                height: 24), // Fish Go 로고
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔧 Flask 서버 연결 상태를 표시하는 컨테이너 (SingleChildScrollView 위에 추가)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.black12,
            child: Text(
              "서버 연결 상태: $serverStatus", // 🔧 연결 상태 출력
              style: const TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🔵 검색 바 + 물때 정보
                  GestureDetector(
                    onTap: () {
                      // 전체 영역 클릭 시 날씨 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WeatherScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF4A68EA), // 진한 파랑색
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              readOnly: true, // 입력 불가로 설정하여 키보드가 뜨지 않도록 함
                              onTap: () {
                                // 검색바 클릭 시에도 날씨 페이지로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WeatherScreen()),
                                );
                              },
                              decoration: InputDecoration(
                                hintText: "지역을 검색하세요",
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.black54),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 🌙 물때 정보 문구
                          const Text(
                            "오늘의 물때를 확인하세요!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 날짜 & 물때 정보 + moon1 이미지 배치
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tideInfo, // 변수 사용
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/icons/moon1.png',
                                height: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🟩 아이콘 메뉴 그리드
                  Container(
                    width: double.infinity, // 좌우 고정
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8), // 상단, 좌우 여백 유지
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double itemWidth =
                            (constraints.maxWidth - 15) / 4; // 4개의 열, 간격 고려
                        double itemHeight = itemWidth + 20; // 아이콘 + 텍스트 높이 고려
                        int rowCount = (8 / 4).ceil(); // 아이콘 개수를 직접 반영 (8개 기준)
                        return SizedBox(
                          height: rowCount * itemHeight, // 행 수에 따라 높이 자동 조정
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4, // 4개의 열 유지
                            mainAxisSpacing: 5, // 세로 간격 조정
                            crossAxisSpacing: 5, // 가로 간격 조정
                            children: [
                              _MenuItem(
                                image: 'assets/icons/map_icon.png',
                                label: "서식지",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FishHabitatScreen(),
                                    ),
                                  );
                                },
                              ),
                              _MenuItem(
                                image: 'assets/icons/no_fish.png',
                                label: "금어기",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ClosedSeasonScreen(),
                                    ),
                                  );
                                },
                              ),
                              _MenuItem(
                                  image:
                                      'assets/icons/book_icon.png', // 도감 버튼 수정
                                  label: "도감",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PictorialBookScreen()),
                                    );
                                  }),
                              _MenuItem(
                                  image: 'assets/icons/fish_icon3.png',
                                  label: "유사종"),
                              _MenuItem(
                                  image: 'assets/icons/contents_icon.png',
                                  label: "콘텐츠"),
                              _MenuItem(
                                  image: 'assets/icons/news_icon.png',
                                  label: "뉴스"),
                              _MenuItem(
                                image: 'assets/icons/fish_icon4.png',
                                label: "방생기준",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ReleaseCriteriaPage(),
                                    ),
                                  );
                                },
                              ),
                              _MenuItem(
                                image: 'assets/icons/tac.png',
                                label: "TAC",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TACScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // 📰 실시간 인기글 컨테이너
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 타이틀 & 더보기 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "최신 게시글",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CommunityScreen(),
                                  ),
                                );
                              },
                              child: const Text("더보기 >"),
                            ),
                          ],
                        ),
                        latestPosts.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "최신 게시글이 없습니다",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Column(
                                children: latestPosts
                                    .take(2) // 최대 2개만 보여줌
                                    .map((post) {
                                  final imageUrl = post['image_url'] ?? '';
                                  final isNetwork = imageUrl.startsWith('/');
                                  return GestureDetector(
                                    onTap: () async {
                                      final postId = post['post_id'];
                                      try {
                                        final response =
                                            await dio.get("/api/posts/$postId");
                                        if (response.statusCode == 200) {
                                          final jsonData = response.data;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ContentReaderScreen(
                                                image: jsonData['image_url'],
                                                title: jsonData['title'],
                                                location: jsonData['location'],
                                                price: jsonData['price'],
                                                comments:
                                                    jsonData['comment_count'],
                                                likes: jsonData['like_count'],
                                                tagColor: Color(int.parse(
                                                    jsonData['tagColor']
                                                        .replaceFirst(
                                                            '#', '0xff'))),
                                                username: jsonData['username'],
                                                userRegion:
                                                    jsonData['userRegion'],
                                                postId: jsonData['post_id'],
                                                postUid: jsonData['uid'],
                                                currentUserUid:
                                                    jsonData['currentUserUid'],
                                                content: jsonData['content'],
                                                createdAt:
                                                    jsonData['created_at'],
                                                status: jsonData['status'],
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "게시글 상세 정보 로드 실패: ${response.statusCode}")),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text("오류 발생: $e")),
                                        );
                                      }
                                    },
                                    child: _PopularPost(
                                      image: isNetwork
                                          ? '${dio.options.baseUrl}$imageUrl'
                                          : 'assets/images/noimage.png',
                                      title: post['title'],
                                      location:
                                          '${post['location']} · ${post['created_at'].substring(11, 16)}',
                                      price: '${post['price']}원',
                                      comments: post['comment_count'],
                                      likes: post['like_count'],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                  // 📰 오늘의 뉴스 컨테이너
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목 & 더보기 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "오늘의 뉴스",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text("더보기 >"),
                            ),
                          ],
                        ),
                        // 뉴스 이미지
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/news_image.png',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // 고정된 버튼과 여백 조절
                ],
              ),
            ),
          ),
          // 🐟 물고기 분류하기 버튼 (고정)
          Container(
            color: const Color(0xFFF4F5F7),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3D8FF), // 연한 파랑색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                // select_photo_screen.dart로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SelectPhotoScreen()),
                );
              },
              icon: Image.asset('assets/icons/fish_icon2.png', height: 24),
              label: const Text(
                "물고기 분류하기",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      // 하단 네비게이션 바 (고정)
      // 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // 현재 선택된 인덱스
        onTap: (index) async {
          if (index == 1) {
            Navigator.push(
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
            Navigator.push(
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
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageSquare), label: "커뮤니티"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.star), label: "내 포인트"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.dollarSign), label: "싯가"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이페이지"),
        ],
      ),
    );
  }
}

// 🟩 메뉴 아이템 위젯
class _MenuItem extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback? onTap; // onTap 추가

  const _MenuItem({required this.image, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 클릭 가능하도록 수정
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9), // 회색
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// 📰 인기글 위젯
class _PopularPost extends StatefulWidget {
  final String image;
  final String title;
  final String location;
  final String price;
  final int comments;
  final int likes;
  // final VoidCallback? onTap; // 👈 추가
  // final int postId; // 👈 추가

  const _PopularPost({
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.comments,
    required this.likes,
    // required this.postId, // 👈 추가
    // this.onTap,
    super.key,
  });

  @override
  State<_PopularPost> createState() => _PopularPostState();
}

class _PopularPostState extends State<_PopularPost> {
  bool isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes; // 초기 좋아요 개수 설정
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 게시글 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: widget.image.startsWith('http')
                ? Image.network(
                    widget.image,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/noimage.png',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    widget.image,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 10),
          // 게시글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // 위치 정보
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.location,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 가격 & 좋아요, 댓글 (우측 정렬)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 💰 가격 (좌측 정렬)
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    // ❤️ 좋아요 & 💬 댓글 (우측 정렬)
                    Row(
                      children: [
                        const Icon(Icons.comment, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${widget.comments}",
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        // 좋아요 버튼 (클릭 시 색상 변경)
                        GestureDetector(
                          onTap: toggleLike,
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 16,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text("$likeCount",
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
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
    );
  }
}
