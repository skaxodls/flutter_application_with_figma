import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

//service screen
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';
import 'package:flutter_application_with_figma/screens/pictorial_book_screen.dart';
import 'package:flutter_application_with_figma/screens/community_screen.dart';
import 'package:flutter_application_with_figma/screens/market_price_screen.dart';

//transaction screen
import 'package:flutter_application_with_figma/screens/favorite_screen.dart';
import 'package:flutter_application_with_figma/screens/trade_calendar_screen.dart';
import 'package:flutter_application_with_figma/screens/trade_history_screen.dart';
import 'package:flutter_application_with_figma/screens/local_post_screen.dart';
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart';

class MyPageLoginScreen extends StatefulWidget {
  const MyPageLoginScreen({super.key});

  @override
  State<MyPageLoginScreen> createState() => _MyPageLoginScreenState();
}

class _MyPageLoginScreenState extends State<MyPageLoginScreen> {
  String username = '';
  String region = '';
  int uid = 0;
  String user_id = '';

  List myPosts = [];
  bool isPostsLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchMyPosts();
  }

  // 내가 작성한 글을 불러오는 함수 (예: /api/my_posts 엔드포인트)
  Future<void> fetchMyPosts() async {
    try {
      final response = await dio.get('/api/my_posts');
      if (response.statusCode == 200) {
        setState(() {
          myPosts = response.data; // 엔드포인트 응답에 따라 List 형태로 가정
          isPostsLoading = false;
        });
      } else {
        setState(() => isPostsLoading = false);
        print("내 글 불러오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isPostsLoading = false);
      print("내 글 불러오기 에러: $e");
    }
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
          user_id = data['user_id'];
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
              Row(
                children: [
                  Text(
                    username,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8), // 가로 간격
                  Text(
                    " $user_id",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              Text(
                region,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Image.asset(
              "assets/mypage_images/setting.png",
              width: 30,
              height: 30,
            ),
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
                "내 낚시 포인트",
                "assets/mypage_images/map_icon2.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyPointScreen()),
                  );
                },
              ),
              _serviceImageIcon(
                "어류 도감",
                "assets/mypage_images/book_icon2.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PictorialBookScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _serviceImageIcon(
                "커뮤니티",
                "assets/mypage_images/community.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityScreen()),
                  );
                },
              ),
              _serviceImageIcon(
                "싯가",
                "assets/mypage_images/coin.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MarketPriceScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceImageIcon(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
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

  Widget _buildMyTransactions() {
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
          _transactionItem(
            "찜한 목록",
            Icons.favorite,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
          _transactionItem(
            "거래 일정 관리",
            Icons.calendar_today,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TradeCalendarScreen()),
              );
            },
          ),
          _transactionItem(
            "판매 내역",
            null,
            imagePath: "assets/mypage_images/bill.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TradeHistoryScreen(initialTab: 1)),
              );
            },
          ),
          _transactionItem(
            "구매 내역",
            null,
            imagePath: "assets/mypage_images/shopping-basket.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TradeHistoryScreen(initialTab: 2)),
              );
            },
          ),
          _transactionItem(
            "내 활동구역 글 모아보기",
            null,
            imagePath: "assets/mypage_images/post_icon.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LocalPostScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(String title, IconData? icon,
      {String? imagePath, VoidCallback? onTap}) {
    return ListTile(
      leading: imagePath != null
          ? Image.asset(imagePath, width: 24, height: 24)
          : Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: onTap,
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
      child: isPostsLoading
          ? const Center(child: CircularProgressIndicator())
          : myPosts.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "내가 작성한 글",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TradeHistoryScreen(initialTab: 0),
                              ),
                            );
                          },
                          child: const Text(
                            "더보기 >",
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myPosts.length,
                      itemBuilder: (context, index) {
                        final post = myPosts[index];
                        final title = post['title'] ?? "";
                        final createdAt = post['created_at'] ?? "";
                        final price = post['price']?.toString() ?? "";

                        // image_url이 문자열인지 리스트인지 확인 후 처리
                        final dynamic imageData = post['image_url'];
                        String? imageUrlStr;
                        if (imageData == null) {
                          imageUrlStr = null;
                        } else if (imageData is List && imageData.isNotEmpty) {
                          // 리스트라면 첫번째 딕셔너리 또는 문자열의 "image_url" 값을 사용
                          if (imageData[0] is Map &&
                              imageData[0]['image_url'] != null) {
                            imageUrlStr = imageData[0]['image_url'];
                          } else if (imageData[0] is String) {
                            imageUrlStr = imageData[0];
                          }
                        } else if (imageData is String) {
                          imageUrlStr = imageData;
                        }

                        // 이미지 위젯 결정: 자산 이미지(asset)와 네트워크 이미지 구분
                        Widget leadingWidget;
                        if (imageUrlStr != null) {
                          if (imageUrlStr.startsWith("assets/")) {
                            // 자산(assets) 이미지인 경우
                            leadingWidget = Image.asset(
                              imageUrlStr,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          } else if (imageUrlStr.startsWith('/')) {
                            // 상대 경로면 네트워크 이미지로 처리 (기본적으로 127.0.0.1:5000 뒤에 붙임)
                            final fullImageUrl =
                                "http://127.0.0.1:5000$imageUrlStr";
                            leadingWidget = Image.network(
                              fullImageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          } else {
                            // 그 외 문자열이면 네트워크 이미지로 사용
                            leadingWidget = Image.network(
                              imageUrlStr,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          }
                        } else {
                          leadingWidget = const Icon(Icons.image, size: 60);
                        }

                        return ListTile(
                            leading: leadingWidget,
                            title: Text(
                              title,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("$createdAt\n가격: ${price}원"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              try {
                                final response = await dio
                                    .get('/api/posts/${post['post_id']}');
                                if (response.statusCode == 200) {
                                  final detail = response.data;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContentReaderScreen(
                                        image: detail['image_url'],
                                        title: detail['title'],
                                        location: detail['location'],
                                        price: detail['price'],
                                        comments: 0,
                                        likes: detail['like_count'],
                                        tagColor: Color(int.parse(
                                            detail['tagColor']
                                                .replaceFirst('#', '0xff'))),
                                        username: detail['username'],
                                        userRegion: detail['userRegion'],
                                        postId: detail['post_id'],
                                        postUid: detail['uid'],
                                        currentUserUid:
                                            detail['currentUserUid'],
                                        content: detail['content'],
                                        createdAt: detail['created_at'],
                                        status: detail['status'],
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('게시글 상세 정보 가져오기 실패: $e');
                              }
                            });
                      },
                    ),
                  ],
                ),
    );
  }
}
