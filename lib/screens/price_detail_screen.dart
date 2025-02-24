import 'package:flutter/material.dart';

class PriceDetailScreen extends StatelessWidget {
  const PriceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // ✅ 배경색 적용
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A68EA), // ✅ 헤더 색상 적용
        title: const Text("감성돔", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🐟 물고기 이미지
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/fish_image12.png",
                  height: 200, // ✅ 이미지 크기 조정
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // 🔹 물고기 이름 + 좋아요/공유 아이콘
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "감성돔",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite,
                          color: Color(0xFFFF473E)), // ✅ 좋아요 아이콘 (빨간색)
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 📌 "국산 / 자연산" 타이틀 및 가격 정보 포함 ✅
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0), // ✅ 좌우 패딩 제거
            child: Container(
              width: double.infinity, // ✅ 전체 너비 차지하도록 설정
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 "국산 / 자연산" 타이틀
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16), // ✅ 좌측 정렬 유지
                    child: Text(
                      "국산 / 자연산",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔹 "활어 kg당" 타이틀 + 아이콘 포함 ✅
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/small_stick_icon.png",
                          height: 12, // ✅ 아이콘 크기 조정
                        ),
                        const SizedBox(width: 8), // ✅ 간격 조정
                        const Text(
                          "활어",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "kg 당",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A68EA), // ✅ 파란색 적용
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 📌 가격 리스트 ✅ (한 컨테이너에 포함)
                  const _PriceRow(
                      label: "소", weight: "1kg 미만", price: "50,000원"),
                  const _PriceRow(
                      label: "중", weight: "1~2kg 미만", price: "49,000원"),
                  const _PriceRow(
                      label: "대", weight: "2~3kg 미만", price: "60,000원"),
                ],
              ),
            ),
          ),
        ],
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

// 📌 가격 행 위젯 (아이콘 포함 + 간격 조정)
class _PriceRow extends StatelessWidget {
  final String label;
  final String weight;
  final String price;

  const _PriceRow({
    required this.label,
    required this.weight,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // ✅ 좌우 정렬 조정
      child: Row(
        children: [
          // 🔹 아이콘 추가
          Image.asset(
            "assets/icons/small_stick_icon.png",
            height: 12,
          ),
          const SizedBox(width: 8), // ✅ 간격 조정

          // 🔹 소/중/대 라벨
          SizedBox(
            width: 24, // ✅ 고정 너비 설정 (일관성 유지)
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 12), // ✅ 라벨과 무게 정보 간격

          // 🔹 무게 정보
          Expanded(
            child: Text(
              weight,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),

          // 🔹 가격 정보 (우측 정렬)
          Text(
            price,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
