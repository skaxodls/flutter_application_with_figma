import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'fish_detail_screen.dart';

import 'package:intl/intl.dart'; // 날짜 선택을 위한 패키지
import 'package:webview_flutter/webview_flutter.dart'; // 카카오 지도 API를 위한 웹뷰 패키지
import 'package:flutter_application_with_figma/screens/kakao_map_screen.dart'; // 카카오 지도 다이얼로그 화면

class FishDetailScreen extends StatefulWidget {
  final int fishNumber;
  final String fishName;
  final String scientificName;
  final String morphologicalInfo; // 형태생태정보
  final String taxonomy; // 계통분류

  const FishDetailScreen({
    super.key,
    required this.fishNumber,
    required this.fishName,
    required this.scientificName,
    required this.morphologicalInfo,
    required this.taxonomy,
  });

  @override
  _FishDetailScreenState createState() => _FishDetailScreenState();
}

class _FishDetailScreenState extends State<FishDetailScreen> {
  // 낚시 로그 리스트 (사용자가 추가한 로그 저장)
  final List<Map<String, dynamic>> _fishingLogs = [];

  // 예상 싯가 합계 계산 함수
  int _calculateTotalEarnings() {
    return _fishingLogs.fold(0, (sum, log) {
      return sum + (int.tryParse(log["price"]?.toString() ?? "0") ?? 0);
    });
  }

// ✅ 낚시 로그 추가 다이얼로그
  void _showAddLogDialog() {
    TextEditingController locationController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController lengthController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    // ✅ 날짜 선택 함수
    Future<void> _selectDate() async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    }

    // ✅ 카카오 지도에서 위치 선택
    Future<void> _selectLocation() async {
      final selectedLocation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KakaoMapScreen(), // ✅ 파일명 일치
        ),
      );

      if (selectedLocation != null) {
        setState(() {
          locationController.text = selectedLocation;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("낚시 로그 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "낚시 포인트",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: _selectLocation,
                  ),
                ),
                readOnly: true,
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: "일시",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
              ),
              TextField(
                controller: lengthController,
                decoration: const InputDecoration(labelText: "체장 (cm)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "무게 (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "예상 싯가",
                  suffixText: "₩",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _fishingLogs.add({
                    "location": locationController.text,
                    "date": dateController.text,
                    "length": lengthController.text,
                    "weight": weightController.text,
                    "price": priceController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  // 현재 로그인한 사용자가 잡은 물고기가 등록되었는지 확인하는 API 호출
  Future<bool> isFishRegistered() async {
    final response = await http.get(Uri.parse(
        "http://127.0.0.1:5000/api/caught_fish?uid=1&fish_id=${widget.fishNumber}"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.isNotEmpty;
    } else {
      return false;
    }
  }

  // 특정 물고기의 출몰지역 정보를 가져오는 API 호출
  Future<List<dynamic>> fetchFishRegions() async {
    final response = await http.get(Uri.parse(
        "http://127.0.0.1:5000/api/fish_regions?fish_id=${widget.fishNumber}"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("낚시 포인트 정보를 불러오지 못했습니다.");
    }
  }

  // 지역 정보를 하나의 문자열로 결합 (지역명, 상세주소)
  String formatRegionInfo(List<dynamic> regions) {
    return regions
        .map((region) =>
            "${region['region_name'] ?? ''} (${region['detailed_address'] ?? ''})")
        .join(", ");
  }

  // 물고기 이미지 URL 결정: 잡은 물고기 등록 여부에 따라 매핑된 이미지 또는 기본 이미지 반환
  Future<String> determineFishImage() async {
    bool registered = await isFishRegistered();
    const String serverUrl = "http://127.0.0.1:5000";
    if (registered) {
      Map<int, String> mapping = {
        1: '/static/images/neobchinongeo.jpg',
        2: '/static/images/nongeo.jpg',
        3: '/static/images/jeomnongeo.jpg',
        4: '/static/images/gamseongdom.jpg',
        5: '/static/images/saenunchi.jpg',
      };
      return serverUrl +
          (mapping[widget.fishNumber] ?? '/static/images/fish_icon7.png');
    } else {
      return serverUrl + '/static/images/fish_icon7.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A68EA),
        title:
            Text(widget.fishName, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/icons/plus_icon.png', height: 24),
            onPressed: _showAddLogDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 물고기 이미지 및 이름 섹션 (FutureBuilder로 이미지 URL 결정)
            FutureBuilder<String>(
              future: determineFishImage(),
              builder: (context, snapshot) {
                String imageUrl = snapshot.hasData
                    ? snapshot.data!
                    : "http://127.0.0.1:5000/static/images/fish_icon7.png";
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC3D8FF),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(100)),
                  ),
                  child: Column(
                    children: [
                      Image.network(imageUrl, height: 120),
                      const SizedBox(height: 10),
                      Text(widget.fishName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Text("학명: ${widget.scientificName}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // 🔹 형태/생태 정보 섹션: fish 테이블의 morphological_info 사용
            _InfoCard(title: "형태/생태 정보", content: widget.morphologicalInfo),
            // 🔹 금어기 & 금지 체장 정보 섹션
            _CombinedInfoCard(
              title: "금어기 & 금지 체장",
              content: "금어기: 시작일~종료일\n금지 체장: 최소크기~최대크기",
            ),
            // 🔹 낚시 포인트 & 지도 섹션 (FutureBuilder로 fish_region 정보 호출)
            FutureBuilder<List<dynamic>>(
              future: fetchFishRegions(),
              builder: (context, snapshot) {
                String fishingPointText = "정보 없음";
                if (snapshot.hasData) {
                  fishingPointText = formatRegionInfo(snapshot.data!);
                }
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA7C6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "낚시 포인트",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fishingPointText,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/map_image.png',
                          width: 120,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // 🔹 계통분류 섹션
            _InfoCard(
              title: "계통분류",
              content: widget.taxonomy,
            ),
            const SizedBox(height: 16),
            // 🎣 낚시 로그 섹션
            if (_fishingLogs.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFA7C6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "낚시 로그",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.fishName} 손익: ${_calculateTotalEarnings()}원",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5E5E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _fishingLogs.map((log) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/fish_image5.png',
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("낚시 포인트: ${log["location"]}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("일시: ${log["date"]}"),
                                    Text("체장 / 무게: ${log["size"]}"),
                                    Text("예상 싯가: ${log["price"]}원",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
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

// 정보 카드 위젯
class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFA7C6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }
}

// 금어기 & 금지 체장 정보 카드 위젯
class _CombinedInfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _CombinedInfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFA7C6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
