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
            ],
          ),
          centerTitle: false,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "품목"),
              Tab(text: "상품"),
            ],
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
