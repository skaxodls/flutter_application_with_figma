import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭 개수
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF3F7EFF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "찜한 목록",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                // TODO: 물음표 아이콘 동작
              },
            ),
          ],
          // ▼ AppBar 아래쪽에 TabBar를 배치하되, 배경을 따로 흰색으로 지정
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.white, // TabBar 배경 흰색
              child: TabBar(
                labelColor: Colors.blue, // 선택된 탭 글씨 파란색
                unselectedLabelColor: Colors.grey, // 선택 안 된 탭 글씨 회색
                indicatorColor: Colors.blue, // 인디케이터 파란색
                tabs: const [
                  Tab(text: "품목"),
                  Tab(text: "상품"),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _FavoriteItemsTab(),
            _FavoriteProductsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          currentIndex: 4, // 원하는 인덱스로 설정
          onTap: (index) {
            // BottomNavigationBar 이동 로직은 여기에 추가
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

class _FavoriteItemsTab extends StatelessWidget {
  const _FavoriteItemsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시용 찜한 품목 더미 데이터
    final List<String> favoriteItems = [
      "경상어",
      "감성동",
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
        final itemName = favoriteItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 22,
              child: Image.asset(
                'assets/icons/profile_icon.png',
                width: 28,
                height: 28,
              ),
            ),
            title: Text(itemName),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // TODO: 찜한 품목 해제 로직 추가
              },
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteProductsTab extends StatelessWidget {
  const _FavoriteProductsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시용 찜한 상품 더미 데이터
    final List<Map<String, dynamic>> favoriteProducts = [
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
        "commentCount": 1,
        "favoriteCount": 2,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            leading: Image.asset(
              product["imagePath"] as String, // Object -> String 타입 캐스팅
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(
              product["title"] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${product["locationTime"]}\n${product["price"]}",
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.comment, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${product["commentCount"]}"),
                const SizedBox(width: 12),
                const Icon(Icons.favorite, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("${product["favoriteCount"]}"),
              ],
            ),
            onTap: () {
              // TODO: 상품 상세 페이지 이동 로직 추가
            },
          ),
        );
      },
    );
  }
}
