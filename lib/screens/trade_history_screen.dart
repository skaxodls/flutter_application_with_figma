import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

class TradeHistoryScreen extends StatefulWidget {
  final int initialTab; // 0: 판매중, 1: 판매내역, 2: 구매내역
  const TradeHistoryScreen({Key? key, required this.initialTab})
      : super(key: key);

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen>
    with SingleTickerProviderStateMixin {
  List sellingItems = []; // 판매중 (판매자가 등록했고 post_status가 '판매중' 또는 '예약중')
  List sellingCompletedItems = []; // 판매내역 (판매자인 경우, post_status가 '거래완료')
  List purchasedItems = []; // 구매내역 (구매자인 경우, post_status가 '거래완료')
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
              preferredSize: const Size.fromHeight(110), // 전체 높이 조정
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
              onTap: (index) {
                // TODO: 하단 네비게이션 이동 로직 작성
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

        // imageUrl이 상대 경로일 경우 "http://127.0.0.1:5000"를 붙여 절대 URL로 변환
        final fullImageUrl = (imageUrl != null && imageUrl.startsWith('/'))
            ? "http://127.0.0.1:5000$imageUrl"
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
            onTap: () {
              // TODO: 상세 페이지 이동 로직
            },
          ),
        );
      },
    );
  }
}
