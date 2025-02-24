import 'package:flutter/material.dart';

class ContentWriterScreen extends StatefulWidget {
  const ContentWriterScreen({super.key});

  @override
  State<ContentWriterScreen> createState() => _ContentWriterScreenState();
}

class _ContentWriterScreenState extends State<ContentWriterScreen> {
  String _selectedStatus = "판매중"; // 초기 상태
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, String>> _comments = [];

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add({"user": "사용자123", "comment": _commentController.text});
        _commentController.clear();
      });
    }
  }

  void _editComment(int index) {
    TextEditingController editController =
        TextEditingController(text: _comments[index]["comment"]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("댓글 수정"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "댓글을 수정하세요"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _comments[index]["comment"] = editController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("수정"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(int index) {
    setState(() {
      _comments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {}, // 기능 추가 가능
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📷 게시글 이미지
            Image.asset(
              'assets/images/fish_image4.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),

            // 👤 프로필 영역
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Image.asset('assets/icons/profile_icon.png',
                      width: 36, height: 36), // ✅ 크기 조정
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "사용자123",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14), // ✅ 텍스트 크기 줄임
                      ),
                      Text(
                        "사용자 주소",
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12), // ✅ 텍스트 크기 줄임
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 🏷 판매 상태, 가격, 제목 (전체 너비 사용)
            Container(
              width: double.infinity, // ✅ 전체 너비 사용
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 드롭다운 버튼 (크기 조정)
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: "판매중",
                        child: Text("판매중"),
                      ),
                      const PopupMenuItem<String>(
                        value: "예약중",
                        child: Text("예약중"),
                      ),
                      const PopupMenuItem<String>(
                        value: "거래완료",
                        child: Text("거래완료"),
                      ),
                    ],
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 70, // ✅ 최소 너비 줄임
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4), // ✅ 패딩 줄임
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // ✅ 최소 크기 조정
                        children: [
                          Text(
                            _selectedStatus,
                            style: const TextStyle(fontSize: 14), // ✅ 텍스트 크기 줄임
                          ),
                          const SizedBox(width: 4),
                          Image.asset('assets/icons/arrow_down_icon.png',
                              width: 14, height: 14), // ✅ 아이콘 크기 줄임
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 💰 가격
                  const Text(
                    "10,000원",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold), // ✅ 텍스트 크기 줄임
                  ),

                  const SizedBox(height: 4),

                  // 📝 제목
                  const Text(
                    "매운탕거리 감성돔 팝니다.",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold), // ✅ 텍스트 크기 줄임
                  ),

                  const SizedBox(height: 4),

                  // ⏳ 업로드 시간
                  const Text(
                    "몇시간 전",
                    style: TextStyle(
                        color: Colors.grey, fontSize: 12), // ✅ 텍스트 크기 줄임
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 📝 글 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: const Text(
                "내용 예시\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n"
                "내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n내용입니다\n",
                style:
                    TextStyle(fontSize: 14, color: Colors.black), // ✅ 텍스트 크기 줄임
              ),
            ),

            const SizedBox(height: 8),
            // 📍 거래 희망 장소
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
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 🗨️ 댓글 영역
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

                  // 댓글 입력 필드
                  Row(
                    children: [
                      Image.asset('assets/icons/profile_icon.png',
                          width: 36, height: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "댓글을 입력하세요...",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _addComment,
                        child: const Text("댓글쓰기"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 댓글 목록
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/icons/profile_icon.png',
                                    width: 30, height: 30),
                                const SizedBox(width: 10),
                                Text(
                                  _comments[index]["user"]!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_comments[index]["comment"]!),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _editComment(index),
                                  child: const Text("댓글수정",
                                      style: TextStyle(fontSize: 12)),
                                ),
                                TextButton(
                                  onPressed: () => _deleteComment(index),
                                  child: const Text("댓글삭제",
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
