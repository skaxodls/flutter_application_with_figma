import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/content_writer_screen.dart'; // 🚀 ContentWriterScreen 추가

class WriteScreen extends StatelessWidget {
  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // 배경색 적용
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "내 물고기 팔기",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {}, // 임시저장 기능 추가 가능
            child: const Text(
              "임시저장",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📷 이미지 업로드 박스
            // 📷 이미지 업로드 박스를 좌측 상단에 배치
            Align(
              alignment: Alignment.topLeft, // 좌측 상단 정렬
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 16), // 아래 여백 추가
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCA), // 연한 회색 배경
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt,
                        size: 40, color: Colors.black), // 카메라 아이콘
                    const SizedBox(height: 5), // 간격 조정
                    const Text("0/10",
                        style: TextStyle(color: Colors.black)), // 텍스트 박스 내부 정렬
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📝 제목 입력 필드
            const Text("제목"),
            const SizedBox(height: 8),
            _CustomTextField(hintText: "제목을 입력하세요"),

            const SizedBox(height: 16),

            // 💰 가격 입력 필드
            const Text("가격"),
            const SizedBox(height: 8),
            _CustomTextField(
                hintText: "가격을 입력하세요", keyboardType: TextInputType.number),

            const SizedBox(height: 16),

            // 📄 설명 입력 필드 (멀티라인)
            const Text("설명"),
            const SizedBox(height: 8),
            _CustomTextField(hintText: "설명을 입력하세요", maxLines: 5),

            const SizedBox(height: 16),

            // 📍 거래 희망 장소 입력 필드
            const Text("거래 희망 장소"),
            const SizedBox(height: 8),
            _CustomTextField(hintText: "거래 희망 장소를 입력하세요"),

            const SizedBox(height: 30),

            // 📌 작성 완료 버튼
            // 📌 작성 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A68EA), // 파란색 버튼
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ContentWriterScreen()), // 🚀 페이지 이동 추가
                  );
                },
                child: const Text(
                  "작성 완료",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40), // 추가 여백
          ],
        ),
      ),

      // 📌 네비게이션 바 (이전 페이지와 동일)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // 기본적으로 커뮤니티 탭 선택
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

// 📝 커스텀 입력 필드 위젯
class _CustomTextField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;

  const _CustomTextField({
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white, // 입력 필드 배경색
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCDCDCD)), // 회색 테두리
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A68EA)), // 포커스 시 파란색
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
