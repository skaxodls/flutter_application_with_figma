import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'fish_detail_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

class PictorialBookScreen extends StatefulWidget {
  const PictorialBookScreen({Key? key}) : super(key: key);

  @override
  State<PictorialBookScreen> createState() => _PictorialBookScreenState();
}

class _PictorialBookScreenState extends State<PictorialBookScreen> {
  // 백엔드 API에서 물고기 데이터를 받아올 Future 변수
  Future<List<dynamic>>? fishDataFuture;

  @override
  void initState() {
    super.initState();
    fishDataFuture = fetchFishData();
  }

  // API 엔드포인트를 호출하여 데이터를 가져옴 (URL은 실제 서버 주소로 수정)
  Future<List<dynamic>> fetchFishData() async {
    final response = await dio.get('/api/fishes');
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    } else {
      throw Exception('데이터 로드 실패');
    }
  }

  /// 총 가격 계산 함수 (API 응답에 price 필드가 포함되어 있다고 가정)
  int _calculateTotalPrice(List<dynamic> fishes) {
    int total = 0;
    for (var fish in fishes) {
      total += ((fish["price"] ?? 0) as num).toInt();
    }
    return total;
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
            onPressed: () {
              // 도움말 기능 추가 가능
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fishDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final fishes = snapshot.data!;
            // taxonomy에 따라 농어과와 도미과로 분류 (필요시 조건 수정)
            final nongEoFishes = fishes
                .where((fish) => (fish['taxonomy'] as String).contains("농어과"))
                .toList();
            final domiFishes = fishes
                .where((fish) => (fish['taxonomy'] as String).contains("도미과"))
                .toList();

            return Column(
              children: [
                // 🔵 카테고리 선택 바
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Image.asset('assets/icons/fish_icon5.png',
                              height: 40),
                          const SizedBox(height: 4),
                          const Text("농어과",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset('assets/icons/fish_icon6.png',
                              height: 40),
                          const SizedBox(height: 4),
                          const Text("도미과",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.add, color: Colors.black, size: 40),
                          const SizedBox(height: 4),
                          const Text("추가중",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.add, color: Colors.black, size: 40),
                          const SizedBox(height: 4),
                          const Text("추가중",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
                // 🔴 싯가 총액 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: const Color(0xFFC3D8FF),
                  width: double.infinity,
                  child: Text(
                    "싯가 총액: ${_calculateTotalPrice(fishes)}원",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5E5E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // 물고기 목록 표시
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🟢 농어과 섹션
                        const Text(
                          "농어과",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                          children: List.generate(nongEoFishes.length, (index) {
                            final fish = nongEoFishes[index];
                            return _FishCard(
                              fishId: fish['fish_id'],
                              fishName: fish['fish_name'],
                              scientificName: fish['scientific_name'] ?? '',
                              price: fish['price'] ?? 0,
                              morphologicalInfo:
                                  fish['morphological_info'] ?? '', // 형태생태정보 추가
                              taxonomy: fish['taxonomy'] ?? '', // taxonomy 추가
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        // 🔴 도미과 섹션
                        const Text(
                          "도미과",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                          children: List.generate(domiFishes.length, (index) {
                            final fish = domiFishes[index];
                            return _FishCard(
                              fishId: fish['fish_id'],
                              fishName: fish['fish_name'],
                              scientificName: fish['scientific_name'] ?? '',
                              price: fish['price'] ?? 0,
                              morphologicalInfo:
                                  fish['morphological_info'] ?? '', // 형태생태정보 추가
                              taxonomy: fish['taxonomy'] ?? '', // taxonomy 추가
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터 로드 실패: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // 🟡 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
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

// 🐟 물고기 카드 위젯
class _FishCard extends StatelessWidget {
  final int fishId;
  final String fishName;
  final String scientificName;
  final int price;
  final String morphologicalInfo; // 형태생태정보 추가
  final String taxonomy;

  const _FishCard({
    Key? key,
    required this.fishId,
    required this.fishName,
    required this.scientificName,
    required this.price,
    required this.morphologicalInfo, // 생성자에 추가
    required this.taxonomy,
  }) : super(key: key);

  Future<bool> _isFishRegistered() async {
    final response = await dio.get('/api/caught_fish?fish_id=$fishId');
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data.isNotEmpty;
    } else {
      return false;
    }
  }

  // 물고기 등록 시 사용할 이미지 매핑 (DB에 저장된 경우 이미 /static/images/ 포함)
  final Map<int, String> fishImageMapping = const {
    1: '/static/images/neobchinongeo.jpg',
    2: '/static/images/nongeo.jpg',
    3: '/static/images/jeomnongeo.jpg',
    4: '/static/images/gamseongdom.jpg',
    5: '/static/images/saenunchi.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 물고기 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FishDetailScreen(
              fishNumber: fishId,
              fishName: fishName,
              scientificName: scientificName,
              morphologicalInfo: morphologicalInfo,
              taxonomy: taxonomy,
            ),
          ),
        );
      },
      child: Container(
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
                "No.$fishId",
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
                  // FutureBuilder를 통해 잡은 물고기 등록 여부에 따라 이미지를 선택
                  FutureBuilder<bool>(
                    future: _isFishRegistered(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 70,
                          width: 70,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        // 오류가 발생하면 기본 이미지를 사용
                        return Image.asset(
                          'assets/icons/fish_icon7.png',
                          height: 70,
                        );
                      } else {
                        final isRegistered = snapshot.data ?? false;
                        if (isRegistered) {
                          // 등록된 경우 매핑된 이미지 URL 사용
                          final mappedImage = fishImageMapping[fishId];
                          if (mappedImage != null) {
                            return Image.network(
                              "${dio.options.baseUrl}" + mappedImage,
                              height: 70,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/icons/fish_icon7.png',
                                  height: 70,
                                );
                              },
                            );
                          } else {
                            return Image.asset(
                              'assets/icons/fish_icon7.png',
                              height: 70,
                            );
                          }
                        } else {
                          // 등록되지 않은 경우 기존 이미지 에셋 사용
                          return Image.asset(
                            'assets/icons/fish_icon7.png',
                            height: 70,
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "싯가 손익",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  Text(
                    "$price원",
                    style: const TextStyle(
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
                          fishName,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                        Text(
                          scientificName,
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
