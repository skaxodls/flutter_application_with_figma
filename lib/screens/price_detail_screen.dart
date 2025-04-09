import 'package:flutter/material.dart';
import 'market_price_screen.dart'; // CombinedFishInfo, MarketPriceFish 모델이 정의된 파일
import 'package:flutter_application_with_figma/screens/community_screen.dart';
import 'package:flutter_application_with_figma/screens/market_price_screen.dart';
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';
import 'package:flutter_application_with_figma/screens/mypage_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';
import 'home_screen.dart';

class PriceDetailScreen extends StatelessWidget {
  final CombinedFishInfo combinedFishInfo;

  const PriceDetailScreen({super.key, required this.combinedFishInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A68EA),
        title: Text(
          combinedFishInfo.name,
          style: const TextStyle(color: Colors.white),
        ),
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
          // 물고기 이미지: 물고기 종에 따라 에셋 이미지 선택
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Image.asset(
                  getAssetImageForFish(combinedFishInfo.name),
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // 물고기 이름과 좋아요/공유 아이콘
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  combinedFishInfo.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.favorite, color: Color(0xFFFF473E)),
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
          // 가격 정보 컨테이너 (가격 리스트 출력)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀 ("국산 / 자연산" 고정 텍스트)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
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
                  // 동적으로 가격 리스트 생성
                  ...combinedFishInfo.allPrices.map((priceInfo) {
                    String weightInfo =
                        "${priceInfo.minWeight.toStringAsFixed(1)}~${priceInfo.maxWeight.toStringAsFixed(1)}kg";
                    String priceText = "${priceInfo.price}원";
                    return _PriceRow(
                      label: priceInfo.sizeCategory,
                      weight: weightInfo,
                      price: priceText,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
      // 하단 네비게이션 바 (디자인 그대로 유지)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
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
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "커뮤니티"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "내 포인트"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "싯가"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이페이지"),
        ],
      ),
    );
  }
}

// 가격 행 위젯 (변경 없음)
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Image.asset(
            "assets/icons/small_stick_icon.png",
            height: 12,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
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

// 물고기 종에 맞게 에셋 이미지 경로를 선택하는 함수
String getAssetImageForFish(String fishName) {
  switch (fishName) {
    case '감성돔':
      return 'assets/images/gamseongdom.jpg';
    case '점농어':
      return 'assets/images/jeomnongeo.jpg';
    case '농어':
      return 'assets/images/nongeo.jpg';
    case '새눈치':
      return 'assets/images/saenunchi.jpg';
    case '넙치농어':
      return 'assets/images/neobchinongeo.jpg';
    default:
      return 'assets/images/default_fish.png';
  }
}
