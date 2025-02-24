import 'package:flutter/material.dart';
import 'price_detail_screen.dart';

class MarketPriceScreen extends StatelessWidget {
  const MarketPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 물고기 리스트 데이터
    final List<Fish> fishList = [
      Fish("농어", "assets/images/fish_image7.png", "25,000"),
      Fish("넙치농어", "assets/images/fish_image8.png", "25,000"),
      Fish("점농어", "assets/images/fish_image9.png", "25,000"),
      Fish("감성돔", "assets/images/fish_image10.png", "49,000"),
      Fish("새눈치", "assets/images/fish_image11.png", "25,000"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A68EA),
        title: const Text("싯가", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // TODO: 도움말 기능 추가 가능
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          itemCount: fishList.length,
          itemBuilder: (context, index) {
            final fish = fishList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFC3D8FF), // 배경색 적용
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🐟 물고기 이미지 (크기 증가)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      fish.imagePath,
                      width: 80, // ✅ 기존보다 크기 증가 (50 → 60)
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 📌 물고기 이름 + 시세 정보
                  // 📌 물고기 이름 + 시세 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 물고기 이름과 "시세 정보 더보기 >"를 같은 Row에 배치
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween, // ✅ 좌측 & 우측 정렬
                          children: [
                            Text(
                              fish.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PriceDetailScreen(
                                        // fishName: fish.name,
                                        // fishPrice: fish.price,
                                        ),
                                  ),
                                );
                              },
                              child: const Text(
                                "시세 정보 더보기 >",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4E4E4E), // ✅ 회색 계열 색상 적용
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // 💰 시세 정보 텍스트 (우측 하단 정렬을 위해 Align 사용)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "${fish.price}원 ~",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // 🟡 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // ✅ "싯가" 탭 활성화
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
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

// 📌 물고기 데이터 모델 클래스
class Fish {
  final String name;
  final String imagePath;
  final String price;

  Fish(this.name, this.imagePath, this.price);
}
