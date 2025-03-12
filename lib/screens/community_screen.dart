import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/write_screen.dart'; // 🚀 WriteScreen 추가
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart'; // 🚀 ContentReaderScreen 추가
import 'home_screen.dart'; // ✅ 홈 화면 추가
import 'mypage_screen.dart';
import 'market_price_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              "Fish Go",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 5),
            Image.asset('assets/icons/fish_icon1.png',
                height: 24), // Fish Go 로고
          ],
        ),
      ),
      body: Expanded(
        child: SingleChildScrollView(
          // ✅ 스크롤 가능하도록 수정
          child: Column(
            children: const [
              _CommunityPost(
                image: 'assets/images/fish_image1.png',
                title: "농어 팝니다",
                location: "포항시 이동 · 20분 전",
                price: "20,000원",
                comments: 3,
                likes: 3,
              ),
              _CommunityPost(
                image: 'assets/images/fish_image2.png',
                title: "갓잡은 감성돔 팝니다",
                location: "남해군 남면 · 1시간 전",
                price: "20,000원",
                comments: 2,
                likes: 5,
                tag: "예약중",
                tagColor: Color(0xFF4A68EA), // 태그 색상 (파랑)
              ),
              _CommunityPost(
                image: 'assets/images/fish_image3.png',
                title: "방어팝니다",
                location: "진해항 부근 · 9시간 전",
                price: "25,000원",
                comments: 1,
                likes: 2,
                tag: "거래완료",
                tagColor: Colors.black, // 태그 색상 (검정)
              ),
              SizedBox(height: 80), // 여백 추가
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WriteScreen()), // 글쓰기 페이지 이동
          );
        },
        backgroundColor: const Color(0xFFD9D9D9), // 글쓰기 버튼 색상
        icon: Image.asset('assets/icons/pencil_icon.png', height: 24),
        label: const Text("글쓰기",
            style: TextStyle(color: Colors.black)), // 글씨 색상 검정
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF999999), // 비활성화 아이콘 색상 적용
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // 현재 선택된 탭 (커뮤니티)
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomeScreen()), // ✅ 홈 화면 이동
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const CommunityScreen()), // ✅ 커뮤니티 화면 유지
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MarketPriceScreen()), // ✅ 싯가 화면 이동
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyPageScreen()), // ✅ 마이페이지 이동
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

// 📰 커뮤니티 게시글 위젯
class _CommunityPost extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String price;
  final int comments;
  final int likes;
  final String? tag;
  final Color? tagColor;

  const _CommunityPost({
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.comments,
    required this.likes,
    this.tag,
    this.tagColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 🔥 클릭 이벤트 추가
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentReaderScreen(
              image: image,
              title: title,
              location: location,
              price: price,
              comments: comments,
              likes: likes,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🐟 게시글 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child:
                  Image.asset(image, height: 95, width: 95, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),

            // 📝 게시글 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 및 태그
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      if (tag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 위치 정보
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF999999)),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                            color: Color(0xFF999999), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 가격 & 좋아요, 댓글
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              size: 16, color: Color(0xFF999999)),
                          const SizedBox(width: 4),
                          Text("$comments",
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.favorite,
                              size: 16, color: Color(0xFF999999)),
                          const SizedBox(width: 4),
                          Text("$likes", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
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
