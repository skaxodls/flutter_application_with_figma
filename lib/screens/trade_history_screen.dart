import 'package:flutter/material.dart';

class TradeHistoryScreen extends StatefulWidget {
  const TradeHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭 개수: 판매중, 거래완료, 구매
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
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
              const SizedBox(width: 10),
              const Text(
                "거래 목록",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "판매중"),
              Tab(text: "거래완료"),
              Tab(text: "구매"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // 판매중 탭
            _SellingTab(),
            // 거래완료 탭
            _CompletedTab(),
            // 구매 탭
            _PurchasedTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          currentIndex: 4, // 원하는 인덱스로 설정
          onTap: (index) {
            // TODO: 원하는 화면으로 이동하는 로직 작성
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: "커뮤니티"),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: "내 포인트"),
            BottomNavigationBarItem(
                icon: Icon(Icons.attach_money), label: "싯가"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이페이지"),
          ],
        ),
      ),
    );
  }
}

// ----------------------- 판매중 탭 -----------------------
class _SellingTab extends StatelessWidget {
  const _SellingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시용 더미 데이터
    final List<Map<String, dynamic>> sellingItems = [
      {
        "title": "농어 팝니다",
        "locationTime": "포항시 이동 · 20분 전",
        "price": "20,000원",
        "imagePath": "assets/images/fish_image1.png",
        "commentCount": 3,
        "favoriteCount": 5,
      },
      {
        "title": "감성동 팝니다",
        "locationTime": "포항 남구 · 1시간 전",
        "price": "45,000원",
        "imagePath": "assets/images/fish_image2.png",
        "commentCount": 2,
        "favoriteCount": 3,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: sellingItems.length,
      itemBuilder: (context, index) {
        final item = sellingItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            leading: Image.asset(
              item["imagePath"] as String,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(
              item["title"] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${item["locationTime"]}\n${item["price"]}"),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.comment, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${item["commentCount"]}"),
                const SizedBox(width: 12),
                const Icon(Icons.favorite, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${item["favoriteCount"]}"),
              ],
            ),
            onTap: () {
              // TODO: 상세 페이지 이동 로직
            },
          ),
        );
      },
    );
  }
}

// ----------------------- 거래완료 탭 -----------------------
class _CompletedTab extends StatelessWidget {
  const _CompletedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시용 더미 데이터
    final List<Map<String, dynamic>> completedItems = [
      {
        "title": "우럭 팝니다",
        "locationTime": "포항시 북구 · 3시간 전",
        "price": "30,000원",
        "imagePath": "assets/images/fish_image1.png",
        "commentCount": 1,
        "favoriteCount": 2,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: completedItems.length,
      itemBuilder: (context, index) {
        final item = completedItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            leading: Image.asset(
              item["imagePath"] as String,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(
              item["title"] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${item["locationTime"]}\n${item["price"]}"),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.comment, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${item["commentCount"]}"),
                const SizedBox(width: 12),
                const Icon(Icons.favorite, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${item["favoriteCount"]}"),
              ],
            ),
            onTap: () {
              // TODO: 상세 페이지 이동 로직
            },
          ),
        );
      },
    );
  }
}

// ----------------------- 구매 탭 -----------------------
class _PurchasedTab extends StatelessWidget {
  const _PurchasedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시용 더미 데이터
    final List<Map<String, dynamic>> purchasedItems = [
      {
        "title": "방어 삽니다",
        "locationTime": "포항시 남구 · 1일 전",
        "price": "40,000원",
        "imagePath": "assets/images/fish_image2.png",
        "commentCount": 0,
        "favoriteCount": 1,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: purchasedItems.length,
      itemBuilder: (context, index) {
        final item = purchasedItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            leading: Image.asset(
              item["imagePath"] as String,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(
              item["title"] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${item["locationTime"]}\n${item["price"]}"),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.comment, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${item["commentCount"]}"),
                const SizedBox(width: 12),
                const Icon(Icons.favorite, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${item["favoriteCount"]}"),
              ],
            ),
            onTap: () {
              // TODO: 상세 페이지 이동 로직
            },
          ),
        );
      },
    );
  }
}
