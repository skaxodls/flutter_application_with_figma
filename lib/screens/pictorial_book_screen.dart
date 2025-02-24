import 'package:flutter/material.dart';
import 'fish_detail_screen.dart';

class PictorialBookScreen extends StatefulWidget {
  const PictorialBookScreen({super.key});

  @override
  State<PictorialBookScreen> createState() => _PictorialBookScreenState();
}

class _PictorialBookScreenState extends State<PictorialBookScreen> {
  final List<Map<String, dynamic>> _fishData = [
    {"number": 1, "price": 0},
    {"number": 2, "price": 0},
    {"number": 3, "price": 0},
    {"number": 4, "price": 0},
    {"number": 5, "price": 0},
  ];

  /// ✅ 총 가격 계산 함수
  int _calculateTotalPrice() {
    return _fishData.fold(0, (sum, item) => sum + (item["price"] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A68EA),
        title: const Text("도감", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {}, // 도움말 기능 추가 가능
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔵 카테고리 선택 바 (배경 흰색, 간격 조정)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Image.asset('assets/icons/fish_icon5.png', height: 40),
                    const SizedBox(height: 4),
                    const Text("농어과",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/icons/fish_icon6.png', height: 40),
                    const SizedBox(height: 4),
                    const Text("도미과",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.add, color: Colors.black, size: 40),
                    const SizedBox(height: 4),
                    const Text("추가중",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.add, color: Colors.black, size: 40),
                    const SizedBox(height: 4),
                    const Text("추가중",
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),

          // 🔴 싯가 총액 표시 (디자인 적용)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFFC3D8FF),
            width: double.infinity,
            child: Text(
              "싯가 총액: ${_calculateTotalPrice()}원",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5E5E),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 📌 물고기 목록
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟢 농어과 섹션 (3개)
                  const Text(
                    "농어과",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: List.generate(3, (index) {
                      return _FishCard(number: _fishData[index]["number"]);
                    }),
                  ),

                  const SizedBox(height: 16),

                  // 🔴 도미과 섹션 (2개)
                  const Text(
                    "도미과",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: List.generate(2, (index) {
                      return _FishCard(number: _fishData[index + 3]["number"]);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🟡 하단 네비게이션 바 (홈 화면과 동일하게 유지)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // ✅ "도감" 탭 활성화
        onTap: (index) {
          // 네비게이션 로직 추가 가능
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

// 🐟 물고기 카드 위젯 (고정 크기 + 물고기명 영역만 흰색 배경)
class _FishCard extends StatelessWidget {
  final int number;
  final String fishName = "넙치농어";
  final String scientificName = "scientific name";

  const _FishCard({
    required this.number,
    // required this.fishName,
    // required this.scientificName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FishDetailScreen(
              fishNumber: number,
              fishName: fishName, // ✅ 물고기명 전달
              scientificName: scientificName, // ✅ 학명 전달
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFC3D8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: 6,
              child: Text(
                "No.$number",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Image.asset('assets/icons/fish_icon7.png', height: 70),
                  const SizedBox(height: 6),
                  const Text(
                    "싯가 손익",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  const Text(
                    "0원",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Text(
                          fishName, // ✅ 전달받은 물고기명 표시
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                        Text(
                          scientificName, // ✅ 전달받은 학명 표시
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black),
                        ),
                      ],
                    ),
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
