import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContentReaderScreen extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final int price;
  final int comments;
  final int likes;
  final String username;
  final String userRegion;
  final int postUid;
  final int currentUserUid;

  const ContentReaderScreen({
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.comments,
    required this.likes,
    required this.username,
    required this.userRegion,
    required this.postUid,
    required this.currentUserUid,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormatted = NumberFormat('#,###').format(price);
    final isAuthor = postUid == currentUserUid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            offset: const Offset(0, 48), // 말풍선 위치 조정
            onSelected: (value) {
              if (value == 'hide') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이 사용자의 글이 더 이상 보이지 않습니다.')),
                );
              } else if (value == 'report') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고가 접수되었습니다.')),
                );
              } else if (value == 'edit') {
                // 수정 기능
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const WriteScreen()), // 예시
                // );
                print('수정하기 클릭');
              } else if (value == 'delete') {
                // 삭제 기능
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('게시글 삭제'),
                    content: const Text('정말 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                          );
                        },
                        child: const Text('삭제',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              if (isAuthor) {
                return const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('수정하기'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('삭제하기'),
                  ),
                ];
              } else {
                return const [
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text('신고하기'),
                  ),
                  PopupMenuItem<String>(
                    value: 'hide',
                    child: Text('이 사용자의 글 보지 않기'),
                  ),
                ];
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Image.asset('assets/icons/profile_icon.png',
                      width: 36, height: 36),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        userRegion,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$priceFormatted원',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: const Text(
                "내용 예시\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "거래희망장소",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "경상남도 창원시 마산합포구 어딘가",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "댓글",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset('assets/icons/profile_icon.png',
                          width: 36, height: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("댓글을 입력하세요..."),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("댓글쓰기"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
