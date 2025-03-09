import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:intl/intl.dart'; // 날짜 선택을 위한 패키지
//import 'package:webview_flutter/webview_flutter.dart'; // 카카오 지도 API를 위한 웹뷰 패키지
import 'package:flutter_application_with_figma/screens/kakao_map_screen.dart'; // 카카오 지도 다이얼로그 화면

import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지

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

  Future<void> _showAddLogDialog() async {
    // 각 입력 필드용 TextEditingController 생성
    TextEditingController locationController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController lengthController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    // 선택한 이미지 경로를 저장할 변수
    String? selectedImagePath;

    Future<void> _selectDate() async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      }
    }

    // 카카오 지도에서 위치 선택
    Future<void> _selectLocation() async {
      final selectedLocation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KakaoMapScreen(),
        ),
      );
      if (selectedLocation != null) {
        locationController.text = selectedLocation.toString();
      }
    }

    // 이미지 선택 함수 (image_picker 사용)
    Future<void> _selectImage() async {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath = image.path;
        print("선택된 이미지 경로: $selectedImagePath");
      } else {
        print("이미지 선택 취소");
      }
    }

    // 다이얼로그 열고 새 로그를 반환받음
    final newLog = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        // 내부 상태 변경을 위해 StatefulBuilder 사용
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("낚시 로그 추가"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. 이미지 선택 영역 (다이얼로그 맨 위에 배치)
                    GestureDetector(
                      onTap: () async {
                        await _selectImage();
                        // 다이얼로그 내부 상태 갱신
                        setState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: selectedImagePath != null
                            ? Image.file(
                                File(selectedImagePath!),
                                fit: BoxFit.cover,
                              )
                            : const Center(child: Text("이미지 선택 (클릭)")),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 2. 낚시 포인트 (카카오 지도 선택)
                    TextField(
                      controller: locationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "낚시 포인트",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: _selectLocation,
                        ),
                      ),
                    ),
                    // 3. 일시 선택
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "일시",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDate,
                        ),
                      ),
                    ),
                    // 4. 체장 입력
                    TextField(
                      controller: lengthController,
                      decoration: const InputDecoration(labelText: "체장 (cm)"),
                      keyboardType: TextInputType.number,
                    ),
                    // 5. 무게 입력
                    TextField(
                      controller: weightController,
                      decoration: const InputDecoration(labelText: "무게 (kg)"),
                      keyboardType: TextInputType.number,
                    ),
                    // 6. 예상 싯가 입력
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    // 새 로그 데이터를 생성하여 반환
                    final newLogData = {
                      "location": locationController.text,
                      "date": dateController.text,
                      "length": lengthController.text,
                      "weight": weightController.text,
                      "price": priceController.text,
                      "image": selectedImagePath ?? "",
                    };
                    Navigator.pop(context, newLogData);
                  },
                  child: const Text("추가"),
                ),
              ],
            );
          },
        );
      },
    );

    if (newLog != null) {
      setState(() {
        _fishingLogs.add(newLog);
      });
    }
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
            // 낚시 로그 섹션 (로그 목록 출력)
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
                              // 이미지 표시: 업로드한 이미지가 있으면 로컬 파일에서 읽고, 없으면 기본 이미지 사용
                              Builder(builder: (context) {
                                if (log["image"] != null &&
                                    log["image"].toString().isNotEmpty) {
                                  String imgPath = log["image"].toString();
                                  if (imgPath.startsWith("http")) {
                                    // 이미 URL 형식이면 네트워크 이미지로
                                    return Image.network(
                                      imgPath,
                                      width: 80,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    // 로컬 파일 경로이면 Image.file로 표시
                                    return Image.file(
                                      File(imgPath),
                                      width: 80,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                } else {
                                  // 이미지가 없을 경우 기본 아이콘 혹은 회색 박스 표시
                                  return Container(
                                    width: 80,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 40),
                                  );
                                }
                              }),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("낚시 포인트: ${log["location"]}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("일시: ${log["date"]}"),
                                    Text(
                                      "체장 / 무게: ${log["length"]} cm / ${log["weight"]} kg",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
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
