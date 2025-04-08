import 'package:flutter/material.dart';
import 'package:flutter_application_with_figma/screens/kakao_map_screen2.dart';
import 'package:flutter_application_with_figma/screens/trade_calendar_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';
import 'write_screen.dart';
import 'kakao_map_screen2.dart';
import 'package:flutter_application_with_figma/screens/trade_history_screen.dart';

Future<void> deletePost(int postId, BuildContext context) async {
  try {
    final response = await dio.delete('/api/posts/$postId');
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 삭제되었습니다.')),
      );
      Navigator.pop(context); // 현재 상세 화면 닫기
    } else {
      throw Exception('삭제 실패');
    }
  } catch (e) {
    print("삭제 오류: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시글 삭제 중 오류가 발생했습니다.')),
    );
  }
}

class ContentReaderScreen extends StatefulWidget {
  final String image;
  final String title;
  final String location;
  final int price;
  final int comments;
  final int likes;
  final Color? tagColor;
  final String username;
  final String userRegion;
  final int postId;
  final int postUid;
  final int currentUserUid;
  final String content;
  final String createdAt;
  final String status;

  const ContentReaderScreen({
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.comments,
    required this.likes,
    this.tagColor,
    required this.username,
    required this.userRegion,
    required this.postId,
    required this.postUid,
    required this.currentUserUid,
    required this.content,
    required this.createdAt,
    required this.status,
    super.key,
  });

  @override
  State<ContentReaderScreen> createState() => _ContentReaderScreenState();
}

class _ContentReaderScreenState extends State<ContentReaderScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> postTrade({
    required int postId,
    required int buyerUid,
    required DateTime tradeDate,
    required String regionName,
    required String detailedAddress,
  }) async {
    try {
      final formattedDate = "${tradeDate.year.toString().padLeft(4, '0')}-"
          "${tradeDate.month.toString().padLeft(2, '0')}-"
          "${tradeDate.day.toString().padLeft(2, '0')} "
          "${tradeDate.hour.toString().padLeft(2, '0')}:"
          "${tradeDate.minute.toString().padLeft(2, '0')}";

      final response = await dio.post(
        '/api/trades',
        data: {
          'post_id': widget.postId,
          'buyer_uid': buyerUid,
          'trade_date': formattedDate,
          'region_name': regionName,
          'detailed_address': detailedAddress,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('거래가 성공적으로 등록되었습니다.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TradeCalendarScreen(),
          ),
        );
      } else {
        throw Exception('거래 등록 실패');
      }
    } catch (e) {
      print('❌ 거래 등록 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('거래 등록 중 오류가 발생했습니다.')),
      );
    }
  }

  void _showBuyerSelectionDialog() {
    final commenters = _comments
        .map((c) => {'uid': c['uid'], 'username': c['username']})
        .toSet()
        .toList(); // 중복 제거

    if (commenters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('거래 가능한 사용자가 없습니다.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('구매자 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: commenters.length,
              itemBuilder: (context, index) {
                final user = commenters[index];
                return ListTile(
                  title: Text(user['username']),
                  onTap: () {
                    Navigator.pop(context); // 닫고 다음 단계로
                    _selectTransactionDate(user['uid'], user['username']);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _selectTransactionDate(int buyerUid, String buyerUsername) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // 앞으로 30일까지
    );

    if (pickedDate != null) {
      // ⏰ 시간 선택
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // 🧠 날짜 + 시간 조합
        final DateTime dateTimeWithTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // 장소 선택 화면으로 이동
        _navigateToKakaoMap(buyerUid, buyerUsername, dateTimeWithTime);
      } else {
        print("❌ 시간 선택 취소됨");
      }
    } else {
      print("❌ 날짜 선택 취소됨");
    }
  }

  void _navigateToKakaoMap(
      int buyerUid, String buyerUsername, DateTime selectedDate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KakaoMapScreen2(),
      ),
    );

    if (result != null && result is String) {
      // 예: "서울 강서구 (마곡동 123-45)"
      final RegExp regex = RegExp(r'^(.*?) \((.*?)\)$');
      final match = regex.firstMatch(result);

      if (match != null) {
        final regionName = match.group(1)!;
        final detailedAddress = match.group(2)!;

        print("✅ 선택된 거래 장소:");
        print("지역명: $regionName");
        print("상세주소: $detailedAddress");

        // 💥 여기서 거래 등록 API 호출
        await postTrade(
          postId: widget.postId,
          buyerUid: buyerUid,
          tradeDate: selectedDate,
          regionName: regionName,
          detailedAddress: detailedAddress,
        );
      } else {
        print("❌ 주소 포맷이 올바르지 않습니다.");
      }
    } else {
      print("❌ 거래 장소 선택이 취소됨");
    }
  }

  Future<void> fetchComments() async {
    try {
      final response = await dio.get('/api/posts/${widget.postId}/comments');
      if (response.statusCode == 200) {
        setState(() {
          _comments = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      print('댓글 불러오기 실패: $e');
    }
  }

  Future<void> submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final response = await dio.post(
        '/api/posts/${widget.postId}/comments',
        data: {'content': commentText},
      );
      if (response.statusCode == 200) {
        _commentController.clear();
        await fetchComments(); // 댓글 다시 불러오기
      } else {
        throw Exception('댓글 등록 실패');
      }
    } catch (e) {
      print('댓글 작성 오류: $e');
    }
  }

  Future<void> deleteCommentWithConfirmation(int commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('정말 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await dio.delete('/api/comments/$commentId');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 삭제되었습니다.')),
        );
        await fetchComments(); // 댓글 목록 새로고침
      } else {
        throw Exception('댓글 삭제 실패');
      }
    } catch (e) {
      print('댓글 삭제 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  String getTimeAgo(String createdAt) {
    final created = DateTime.tryParse(createdAt);
    if (created == null) return '';
    final now = DateTime.now();
    final difference = now.difference(created);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceFormatted = NumberFormat('#,###').format(widget.price);
    final isAuthor = widget.postUid == widget.currentUserUid;
    final createdTimeAgo = getTimeAgo(widget.createdAt);
    final hasImage = widget.image.isNotEmpty &&
        (widget.image.startsWith('/static') || widget.image.startsWith('http'));

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
            offset: const Offset(0, 48),
            onSelected: (value) async {
              if (value == 'hide' || value == 'report') {
                if (widget.currentUserUid == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인이 필요합니다.')),
                  );
                  return;
                }
              }
              if (value == 'hide') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이 사용자의 글이 더 이상 보이지 않습니다.')),
                );
              } else if (value == 'report') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고가 접수되었습니다.')),
                );
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WriteScreen(
                      postId: widget.postId,
                      initialData: {
                        'title': widget.title,
                        'price': widget.price,
                        'content': widget.content,
                        'status': widget.status,
                      },
                    ),
                  ),
                );
              } else if (value == 'delete') {
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
                          deletePost(widget.postId, context);
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
            hasImage
                ? Image.network(
                    'http://127.0.0.1:5000${widget.image}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 80);
                    },
                  )
                : Image.asset(
                    widget.image,
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
                        widget.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        widget.userRegion,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 6),
                        decoration: BoxDecoration(
                          color: widget.tagColor ?? Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$priceFormatted원',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createdTimeAgo,
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
              child: Text(
                widget.content,
                style: const TextStyle(fontSize: 14, color: Colors.black),
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
                  const SizedBox(height: 12),

                  // 댓글 입력창
                  Row(
                    children: [
                      Image.asset('assets/icons/profile_icon.png',
                          width: 36, height: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요...',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: submitComment,
                        child: const Text("댓글쓰기"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 댓글 목록
                  if (_comments.isEmpty)
                    const Text("아직 작성된 댓글이 없습니다.",
                        style: TextStyle(color: Colors.grey)),
                  ..._comments.map((comment) => Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comment['username'] ?? '익명 사용자',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                if (comment['uid'] == widget.currentUserUid)
                                  GestureDetector(
                                    onTap: () => deleteCommentWithConfirmation(
                                        comment['comment_id']),
                                    child: const Icon(Icons.delete,
                                        color: Colors.grey, size: 18),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(comment['content']),
                            const SizedBox(height: 4),
                            Text(
                              getTimeAgo(comment['created_at']),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: widget.postUid == widget.currentUserUid
          ? FloatingActionButton.extended(
              onPressed: () => _showBuyerSelectionDialog(),
              backgroundColor: const Color(0xFF4A68EA),
              icon: const Icon(Icons.handshake),
              label: const Text("거래하기"),
            )
          : null,
    );
  }
}
