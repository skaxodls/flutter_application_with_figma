import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';
import 'kakao_map_screen.dart'; // KakaoMapScreen을 import 합니다.

class MyPointScreen extends StatefulWidget {
  const MyPointScreen({Key? key}) : super(key: key);

  @override
  _MyPointScreenState createState() => _MyPointScreenState();
}

class _MyPointScreenState extends State<MyPointScreen> {
  List<dynamic> _fishingPoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFishingPoints();
  }

  Future<void> _loadFishingPoints() async {
    try {
      final response = await dio.get('/api/fishing_points');
      if (response.statusCode == 200) {
        setState(() {
          _fishingPoints = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Exception: $e');
    }
  }

  // personal_fishing_point 삭제 함수 (region 정보 기반)
  Future<void> _deleteFishingPoint(
      String regionName, String detailedAddress) async {
    try {
      // region 정보를 "region_name (detailed_address)" 형식으로 전달합니다.
      final String regionFull = "$regionName ($detailedAddress)";
      final response = await dio.delete(
        '/api/personal_fishing_point',
        data: {"region": regionFull},
      );
      if (response.statusCode == 200) {
        print("개인 낚시 포인트 삭제 성공: ${response.data}");
        _loadFishingPoints();
      } else {
        print("개인 낚시 포인트 삭제 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("개인 낚시 포인트 삭제 예외: $e");
    }
  }

  // 검색창이나 "현재 위치로 찾기" 버튼을 통해 KakaoMapScreen 호출 (초기주소 없음)
  Future<void> _navigateToKakaoMap() async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KakaoMapScreen()),
    );
    if (selectedAddress != null) {
      print("선택된 주소: $selectedAddress");
      try {
        // POST 요청으로 personal_fishing_point에 저장
        final response = await dio.post(
          '/api/personal_fishing_point',
          data: {"region": selectedAddress},
        );
        if (response.statusCode == 200) {
          print("개인 낚시 포인트 저장 성공: ${response.data}");
          _loadFishingPoints();
        } else {
          print("개인 낚시 포인트 저장 실패: ${response.statusCode}");
        }
      } catch (e) {
        print("개인 낚시 포인트 저장 예외: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "내 포인트",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // 검색 바: readOnly, 탭 시 KakaoMapScreen 호출 (초기주소 없음)
            GestureDetector(
              onTap: _navigateToKakaoMap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "지번, 도로명, 건물명으로 검색",
                      border: InputBorder.none,
                      icon: const Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 현재 위치로 찾기 버튼: 기존 방식대로 KakaoMapScreen 호출 (초기주소 없음)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _navigateToKakaoMap,
                  icon: const Icon(Icons.my_location, color: Colors.black),
                  label: const Text(
                    "현재 위치로 찾기",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F5F7),
                    side: const BorderSide(color: Color(0xFFF4F5F7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            // 개인 낚시 포인트 목록 출력 영역
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _fishingPoints.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final point = _fishingPoints[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined,
                              color: Colors.black),
                          title: Text(
                            point['region_name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(point['detailed_address'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.grey),
                            onPressed: () {
                              final regionName = point['region_name'];
                              final detailedAddress = point['detailed_address'];
                              if (regionName != null &&
                                  detailedAddress != null) {
                                _deleteFishingPoint(
                                    regionName, detailedAddress);
                              } else {
                                print("지역 정보가 없습니다.");
                              }
                            },
                          ),
                          onTap: () {
                            // 내 포인트 목록 항목 클릭 시, detailed_address만 초기주소로 전달
                            final detailedAddress =
                                point['detailed_address'] ?? '';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KakaoMapScreen(
                                    initialAddress: detailedAddress),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
