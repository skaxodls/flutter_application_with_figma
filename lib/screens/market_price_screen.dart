import 'package:flutter/material.dart';
import 'price_detail_screen.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'mypagelogin_screen.dart';
import 'community_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart'; // dio 인스턴스 import
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  _MarketPriceScreenState createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  late Future<List<CombinedFishInfo>> futureCombinedFishList;

  @override
  void initState() {
    super.initState();
    futureCombinedFishList = fetchCombinedFishInfo();
  }

  // 두 API를 동시에 호출하여 데이터를 결합하는 함수
  Future<List<CombinedFishInfo>> fetchCombinedFishInfo() async {
    final marketResponse = await dio.get('/api/market_price');
    final fishResponse = await dio.get('/api/all_fish_info');

    if (marketResponse.statusCode == 200 && fishResponse.statusCode == 200) {
      List<dynamic> marketData = marketResponse.data;
      List<dynamic> fishData = fishResponse.data;

      // 각 API의 JSON 데이터를 모델 객체로 파싱
      List<MarketPriceFish> marketFishList =
          marketData.map((json) => MarketPriceFish.fromJson(json)).toList();
      List<FishDetail> fishDetailList =
          fishData.map((json) => FishDetail.fromJson(json)).toList();

      // 그룹화: 같은 fishId의 가격 정보를 하나의 리스트로 묶기
      Map<int, List<MarketPriceFish>> groupedMarketFish = {};
      for (var marketFish in marketFishList) {
        if (groupedMarketFish.containsKey(marketFish.fishId)) {
          groupedMarketFish[marketFish.fishId]!.add(marketFish);
        } else {
          groupedMarketFish[marketFish.fishId] = [marketFish];
        }
      }

      // 그룹별로 가장 낮은 가격을 선택하고, 모든 가격 정보도 함께 전달
      List<CombinedFishInfo> combinedList = [];
      groupedMarketFish.forEach((fishId, prices) {
        // 가장 낮은 가격 항목 선택
        MarketPriceFish lowestPriceEntry =
            prices.reduce((a, b) => a.price < b.price ? a : b);

        // fish_id를 기준으로 FishDetail 찾기
        var fishDetail = fishDetailList.firstWhere(
          (fish) => fish.fishId == fishId,
          orElse: () => FishDetail.empty('알 수 없음'),
        );

        combinedList.add(
          CombinedFishInfo(
            name: fishDetail.fishName,
            imagePath: getImagePathForFish(fishDetail.fishName),
            price: lowestPriceEntry.price.toString() + "원~", // 낮은 가격에 "~" 추가
            scientificName: fishDetail.scientificName,
            morphologicalInfo: fishDetail.morphologicalInfo,
            taxonomy: fishDetail.taxonomy,
            allPrices: prices, // 해당 물고기의 모든 가격 정보 전달
          ),
        );
      });

      return combinedList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<CombinedFishInfo>>(
        future: futureCombinedFishList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final fishList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                itemCount: fishList.length,
                itemBuilder: (context, index) {
                  final fish = fishList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC3D8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 물고기 이미지
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            fish.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 물고기 이름과 "시세 정보 더보기" 버튼을 같은 Row에 배치
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      // PriceDetailScreen에 결합된 데이터를 전달
                                      // PriceDetailScreen은 전달받은 allPrices를 이용해 모든 가격 정보를 보여줄 예정
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PriceDetailScreen(
                                            combinedFishInfo: fish,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "시세 정보 더보기 >",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF4E4E4E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              // 시세 정보 표시 (예: 가장 낮은 가격)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  fish.price,
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
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // 싯가 탭 활성화
        onTap: (index) async {
          if (index == 4) {
            try {
              final response = await dio.get('/api/check_session');
              final loggedIn = response.statusCode == 200 &&
                  response.data['logged_in'] == true;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => loggedIn
                      ? const MyPageLoginScreen()
                      : const MyPageScreen(),
                ),
              );
            } catch (e) {
              // 실패 시 기본 마이페이지로
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyPageScreen()),
              );
            }
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MarketPriceScreen()),
            );
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

// 물고기 이름에 따라 이미지 경로를 반환하는 함수
String getImagePathForFish(String fishName) {
  switch (fishName) {
    case '농어':
      return 'assets/images/fish_image7.png';
    case '넙치농어':
      return 'assets/images/fish_image8.png';
    case '점농어':
      return 'assets/images/fish_image9.png';
    case '감성돔':
      return 'assets/images/fish_image10.png';
    case '새눈치':
      return 'assets/images/fish_image11.png';
    default:
      return 'assets/images/default_fish.png';
  }
}

// -----------------------
// MarketPrice API 모델 (DB에서 반환하는 데이터 포멧)
// -----------------------
class MarketPriceFish {
  final int fishId;
  final String sizeCategory;
  final double minWeight;
  final double maxWeight;
  final int price;

  MarketPriceFish({
    required this.fishId,
    required this.sizeCategory,
    required this.minWeight,
    required this.maxWeight,
    required this.price,
  });

  factory MarketPriceFish.fromJson(Map<String, dynamic> json) {
    return MarketPriceFish(
      fishId: json['fish_id'],
      sizeCategory: json['size_category'],
      minWeight: (json['min_weight'] as num).toDouble(),
      maxWeight: (json['max_weight'] as num).toDouble(),
      price: json['price'] as int,
    );
  }
}

// -----------------------
// Fish Info API 모델
// -----------------------
class FishDetail {
  final int fishId;
  final String fishName;
  final String scientificName;
  final String morphologicalInfo;
  final String taxonomy;

  FishDetail({
    required this.fishId,
    required this.fishName,
    required this.scientificName,
    required this.morphologicalInfo,
    required this.taxonomy,
  });

  factory FishDetail.fromJson(Map<String, dynamic> json) {
    return FishDetail(
      fishId: json['fish_id'],
      fishName: json['fish_name'],
      scientificName: json['scientific_name'] ?? '',
      morphologicalInfo: json['morphological_info'] ?? '',
      taxonomy: json['taxonomy'] ?? '',
    );
  }

  factory FishDetail.empty(String fishName) {
    return FishDetail(
      fishId: 0,
      fishName: fishName,
      scientificName: '',
      morphologicalInfo: '',
      taxonomy: '',
    );
  }
}

// -----------------------
// 두 API의 데이터를 결합한 모델
// -----------------------
class CombinedFishInfo {
  final String name;
  final String imagePath;
  final String price;
  final String scientificName;
  final String morphologicalInfo;
  final String taxonomy;
  final List<MarketPriceFish> allPrices; // 해당 물고기의 모든 가격 정보

  CombinedFishInfo({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.scientificName,
    required this.morphologicalInfo,
    required this.taxonomy,
    required this.allPrices,
  });
}
