import 'package:flutter/material.dart';

class LocalPostScreen extends StatefulWidget {
  const LocalPostScreen({Key? key}) : super(key: key);

  @override
  State<LocalPostScreen> createState() => _LocalPostScreenState();
}

class _LocalPostScreenState extends State<LocalPostScreen> {
  // 예시용 더미 데이터
  final List<Map<String, dynamic>> localPosts = [
    {
      "title": "농어 팝니다",
      "locationTime": "창원시 사림동 · 20분 전",
      "price": "20,000원",
      "imagePath": "assets/images/fish_image1.png",
      "commentCount": 3,
      "favoriteCount": 5,
    },
    {
      "title": "갓한 감성동 팝니다",
      "locationTime": "창원시 흥림동 · 1시간 전",
      "price": "20,000원",
      "imagePath": "assets/images/fish_image2.png",
      "commentCount": 2,
      "favoriteCount": 3,
    },
    {
      "title": "갓한 감성동 팝니다",
      "locationTime": "창원시 중앙동 · 1시간 전",
      "price": "20,000원",
      "imagePath": "assets/images/fish_image2.png",
      "commentCount": 2,
      "favoriteCount": 3,
    },
    {
      "title": "소방어 팝니다",
      "locationTime": "창원시 내동 · 8시간 전",
      "price": "20,000원",
      "imagePath": "assets/images/fish_image1.png",
      "commentCount": 1,
      "favoriteCount": 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 스크린샷에 파란색 배경의 AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3F7EFF), // 필요 시 색상 코드 조정
        title: Row(
          children: [
            const Text(
              "Fish Go",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 5),
            // 파란 배경에 어두운 아이콘 그대로 사용 (프로젝트에 맞춰 수정)
            Image.asset('assets/icons/fish_icon1.png', height: 24),
            const SizedBox(width: 10),
            // 지역명 표시 (예: 창원시)
            const Text(
              "창원시",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 글 목록
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 60, top: 10),
            itemCount: localPosts.length,
            itemBuilder: (context, index) {
              final post = localPosts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  leading: Image.asset(
                    post["imagePath"] as String,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    post["title"] as String,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${post["locationTime"]}\n${post["price"]}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.comment,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text("${post["commentCount"]}"),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text("${post["favoriteCount"]}"),
                    ],
                  ),
                  onTap: () {
                    // TODO: 글 상세 페이지 이동 로직
                  },
                ),
              );
            },
          ),

          // 하단 오른쪽 "글쓰기" 버튼 (스샷처럼 버튼 형태)
          Positioned(
            bottom: 10,
            right: 15,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
              onPressed: () {
                // TODO: 글쓰기 페이지 이동 로직
              },
              child: const Text("글쓰기"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 4, // 원하는 인덱스로 설정
        onTap: (index) {
          // TODO: 원하는 화면으로 이동하는 로직
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
