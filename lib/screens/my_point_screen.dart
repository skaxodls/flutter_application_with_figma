import 'package:flutter/material.dart';

class MyPointScreen extends StatelessWidget {
  const MyPointScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시 데이터: 주소 목록
    final List<Map<String, String>> addressList = [
      {
        "title": "경남 창원시 성산구 중앙대로39번길 10",
        "subtitle": "몇 분 이내 도착",
      },
      {
        "title": "우리집",
        "subtitle": "경남 창원시 성산구 82-15 1307동 1003호",
      },
      {
        "title": "둥 기숙사",
        "subtitle": "경남 창원시 의창구 창원대로 20 1동",
      },
      {
        "title": "경남 김해시 의창구 창원대로 20",
        "subtitle": "경남 김해시 의창구 창원대로 20 도서관 정문쪽",
      },
      {
        "title": "경남 김해시 진례면 고모로327번길 47",
        "subtitle": "경남 김해시 진례면 고모로327번길 47",
      },
      {
        "title": "경남 김해시 진례면 고모로327번길 32",
        "subtitle": "경남 김해시 진례면 고모로327번길 32",
      },
    ];

    return Scaffold(
      // 1) 화면 배경색 화이트로 변경
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 2) 제목 "주소 설정" 중앙 정렬 + 검정색 텍스트
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
            // 검색 바
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "지번, 도로명, 건물명으로 검색",
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 현재 위치로 설정 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 현재 위치로 찾기 동작
                  },
                  icon: const Icon(Icons.my_location, color: Colors.black),
                  label: const Text(
                    "현재 위치로 찾기",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    // 박스 내부 색과 외곽선 색을 동일하게 지정
                    backgroundColor: const Color(0xFFF4F5F7),
                    side: const BorderSide(color: Color(0xFFF4F5F7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // 버튼 높이 확보
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            // 주소 목록
            Expanded(
              child: ListView.separated(
                itemCount: addressList.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final address = addressList[index];
                  return ListTile(
                    // 4) 왼쪽에 위치 아이콘 추가
                    leading: const Icon(Icons.location_on_outlined,
                        color: Colors.black),
                    title: Text(
                      address["title"] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(address["subtitle"] ?? ""),
                    // 5) 오른쪽에 삭제 아이콘 추가
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () {
                        // TODO: 주소 삭제 기능
                      },
                    ),
                    onTap: () {
                      // TODO: 주소 항목 선택 시 동작
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
