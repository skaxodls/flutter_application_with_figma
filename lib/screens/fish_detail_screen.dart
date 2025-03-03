import 'package:flutter/material.dart';

class FishDetailScreen extends StatefulWidget {
  final int fishNumber;
  final String fishName;
  final String scientificName;

  const FishDetailScreen({
    super.key,
    required this.fishNumber,
    required this.fishName,
    required this.scientificName,
  });

  @override
  _FishDetailScreenState createState() => _FishDetailScreenState();
}

class _FishDetailScreenState extends State<FishDetailScreen> {
  // ✅ 낚시 로그 리스트 (사용자가 추가한 로그 저장)
  final List<Map<String, dynamic>> _fishingLogs = [];

// ✅ 예상 싯가 합계를 계산하는 함수 (예외 방지 적용)
  int _calculateTotalEarnings() {
    return _fishingLogs.fold(0, (sum, log) {
      return sum + (int.tryParse(log["price"]?.toString() ?? "0") ?? 0);
    });
  }

  // ✅ 낚시 로그 추가 다이얼로그
  void _showAddLogDialog() {
    TextEditingController locationController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController sizeController = TextEditingController();
    TextEditingController priceController = TextEditingController();

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
                decoration: const InputDecoration(labelText: "낚시 포인트"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "일시"),
              ),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: "체장 / 무게"),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "예상 싯가"),
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
                    "size": sizeController.text,
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
            onPressed: _showAddLogDialog, // ✅ 다이얼로그 표시
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 물고기 이미지 및 이름
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFC3D8FF),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(100)),
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/fish_image5.png', height: 120),
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
            ),
            const SizedBox(height: 16),

            // 🔹 정보 섹션 (형태/생태, 금어기, 금지 체장 등)
            _InfoCard(title: "형태/생태 정보", content: "머리부터 뒷줄까지 오로라한 C"),
            // 🔹 금어기 & 금지 체장 (하나의 박스로 통합)
            _CombinedInfoCard(
              title: "금어기 & 금지 체장",
              content: "금어기: 시작일~종료일\n금지 체장: 최소크기~최대크기",
            ),
            // 🔹 낚시 포인트 & 지도 (Row로 가로 배치)
            Container(
              width: double.infinity,
              padding: EdgeInsets.zero, // ✅ 모든 패딩을 0으로 설정
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7), // ✅ 흰색 배경 컨테이너 추가
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🎣 낚시 포인트 정보 (푸른빛 박스)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA7C6FF), // ✅ 푸른빛 배경 추가
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "낚시 포인트",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "시작일~종료일",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10), // ✅ 간격 조정

                  // 🗺 지도 이미지 (오른쪽)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/map_image.png',
                      width: 120, // ✅ 지도 크기 조정
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 계통분류 섹션
            _InfoCard(
              title: "계통분류",
              content: """
계: 동물계 (Metazoa)
문: 척삭동물문 (Chordata)
강: 조기어강 (Actinopteri)
목: 주걱치목 or 농어목 (Pempheriformes)
과: 농어과 (Lateolabracidae)
속: 농어속 (Lateolabrax)
종: 넙치농어 (Latus)
              """,
            ),

            const SizedBox(height: 16),

            // 🎣 낚시 로그 (추가된 로그 리스트)
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
                    // ✅ 낚시 로그 제목 + 총 손익 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "낚시 로그",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "넙치농어 손익: ${_calculateTotalEarnings()}원",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5E5E), // ✅ 빨간색 강조
                          ),
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

// 📌 정보 카드 위젯 추가 ✅
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

// 📌 금어기 & 금지 체장 정보 카드 위젯 (하나의 박스)
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
