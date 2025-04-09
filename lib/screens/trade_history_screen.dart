import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';
import 'package:flutter_application_with_figma/screens/community_screen.dart';
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';
import 'package:flutter_application_with_figma/screens/market_price_screen.dart';
import 'package:flutter_application_with_figma/screens/mypage_screen.dart';
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';
import 'content_reader_screen.dart'; // ContentReaderScreen의 위치에 맞게 import 경로를 수정하세요.

class TradeHistoryScreen extends StatefulWidget {
  final int initialTab; // 0: 판매중, 1: 판매내역, 2: 구매내역
  const TradeHistoryScreen({Key? key, required this.initialTab})
      : super(key: key);

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen>
    with SingleTickerProviderStateMixin {
  List sellingItems = []; // 판매중
  List sellingCompletedItems = []; // 판매내역
  List purchasedItems = []; // 구매내역
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    fetchTradeHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchTradeHistory() async {
    try {
      final response = await dio.get("/api/trade_history");
      if (response.statusCode == 200) {
        final jsonData = response.data;
        setState(() {
          sellingItems = jsonData['sellingItems'];
          sellingCompletedItems = jsonData['sellingCompletedItems'];
          purchasedItems = jsonData['purchasedItems'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Failed to load trade history: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching trade history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            backgroundColor: const Color(0xFFF4F5F7),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 상단 파란색 영역
                  Container(
                    height: 60,
                    color: const Color(0xFF4A68EA),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "거래 목록",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // 하단 흰색 영역의 TabBar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicatorColor: Colors.black,
                      tabs: const [
                        Tab(text: "판매중"),
                        Tab(text: "판매내역"),
                        Tab(text: "구매내역"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                TradeListWidget(trades: sellingItems),
                TradeListWidget(trades: sellingCompletedItems),
                TradeListWidget(trades: purchasedItems),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              currentIndex: 4, // 네비게이션바의 현재 선택된 인덱스
              onTap: (index) async {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityScreen()),
                  );
                } else if (index == 2) {
                  // 내 포인트 버튼 클릭 시
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyPointScreen()),
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
                      MaterialPageRoute(
                          builder: (context) => const MyPageScreen()),
                    );
                  }
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.message), label: "커뮤니티"),
                BottomNavigationBarItem(icon: Icon(Icons.star), label: "내 포인트"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money), label: "싯가"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "마이페이지"),
              ],
            ),
          );
  }
}

class TradeListWidget extends StatelessWidget {
  final List trades;
  const TradeListWidget({Key? key, required this.trades}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return const Center(child: Text("표시할 거래 내역이 없습니다."));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        final title = trade['title'] ?? "";
        final tradeDate = trade['trade_date'] ?? "";
        final price = trade['price']?.toString() ?? "";
        final postStatus = trade['post_status'] ?? "";
        final imageUrl = trade['image_url'];

        // imageUrl이 상대경로면 절대 URL로 변환
        final fullImageUrl = (imageUrl != null && imageUrl.startsWith('/'))
            ? "${dio.options.baseUrl}$imageUrl"
            : imageUrl;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            leading: fullImageUrl != null
                ? Image.network(
                    fullImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 60),
            title: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("$tradeDate\n가격: ${price}원\n상태: $postStatus"),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // trade 객체에 post_id가 존재한다고 가정합니다.
              final postId = trade['post_id'];
              try {
                final response = await dio.get("/api/posts/$postId");
                if (response.statusCode == 200) {
                  final jsonData = response.data;
                  // 상세 페이지로 이동하면서 API 응답 데이터를 생성자 인자로 전달합니다.
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
                        tagColor: Color(int.parse(
                            jsonData['tagColor'].replaceFirst('#', '0xff'))),
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
                  print("Failed to load post detail: ${response.statusCode}");
                }
              } catch (e) {
                print("Error fetching post detail: $e");
              }
            },
          ),
        );
      },
    );
  }
}
