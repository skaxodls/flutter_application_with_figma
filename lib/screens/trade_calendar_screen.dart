import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_with_figma/dio_setup.dart'; // 전역 dio 인스턴스 import
import 'package:flutter_application_with_figma/screens/content_reader_screen.dart'; // ContentReaderScreen import

// 거래 데이터를 표현하는 모델 클래스 (buyer_name 필드 사용)
// API 응답의 is_seller 값을 활용하기 위해 isSeller 필드 추가
class Trade {
  final DateTime tradeDate;
  final String time;
  final String address;
  final String title;
  final int price;
  final String buyerName;
  final String sellerName;
  final bool isSeller;
  final String postStatus;
  final int postId;
  final int tradeId;

  Trade({
    required this.tradeDate,
    required this.time,
    required this.address,
    required this.title,
    required this.price,
    required this.buyerName,
    required this.sellerName,
    required this.isSeller,
    required this.postStatus,
    required this.postId,
    required this.tradeId,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      tradeDate: DateTime.parse(json['trade_date']),
      time: json['time'],
      address: json['address'],
      title: json['title'],
      price: json['price'],
      buyerName: json['buyer_name'],
      sellerName: json['seller_name'],
      isSeller: json['is_seller'] as bool,
      postStatus: json['post_status'],
      postId: json['post_id'],
      tradeId: json['trade_id'],
    );
  }
}

class TradeCalendarScreen extends StatefulWidget {
  const TradeCalendarScreen({Key? key}) : super(key: key);

  @override
  State<TradeCalendarScreen> createState() => _TradeCalendarScreenState();
}

class _TradeCalendarScreenState extends State<TradeCalendarScreen> {
  bool _isSelectionMode = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // API에서 받아온 trade 데이터를 날짜별로 그룹핑한 Map
  Map<DateTime, List<Trade>> _tradeData = {};

  @override
  void initState() {
    super.initState();
    fetchTradeData();
  }

  // Dio를 사용해 API에서 거래 데이터를 불러와 _tradeData에 저장
  Future<void> fetchTradeData() async {
    try {
      print("API 요청 시작");
      final response = await dio.get("/api/trades");
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        List<Trade> trades =
            jsonData.map((json) => Trade.fromJson(json)).toList();

        // 거래일별로 그룹핑 (시간은 무시)
        Map<DateTime, List<Trade>> tradeMap = {};
        for (var trade in trades) {
          final key = DateTime(
            trade.tradeDate.year,
            trade.tradeDate.month,
            trade.tradeDate.day,
          );
          if (tradeMap.containsKey(key)) {
            tradeMap[key]!.add(trade);
          } else {
            tradeMap[key] = [trade];
          }
        }
        setState(() {
          _tradeData = tradeMap;
        });
      } else {
        print("Failed to fetch trade data");
      }
    } catch (e) {
      print("Error fetching trade data: $e");
    }
  }

  Future<void> confirmPurchase(Trade trade) async {
    try {
      final response = await dio.post("/api/confirm_purchase", data: {
        "post_id": trade.postId,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("구매확정이 완료되었습니다.")),
        );
        // 최신 거래 데이터를 다시 불러와 UI 갱신
        fetchTradeData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("구매확정 실패")),
        );
      }
    } catch (e) {
      print("Error confirming purchase: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오류가 발생했습니다.")),
      );
    }
  }

  Future<void> deleteTrade(Trade trade) async {
    try {
      final response = await dio.post("/api/delete_trade", data: {
        "trade_id": trade.tradeId,
        "post_id": trade.postId,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("거래가 삭제되었습니다.")),
        );
        // 삭제 후 삭제 모드 종료
        setState(() {
          _isSelectionMode = false;
        });
        // 최신 거래 데이터를 다시 불러와 UI 갱신
        fetchTradeData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("삭제 실패")),
        );
      }
    } catch (e) {
      print("Error deleting trade: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜의 거래 데이터 (없으면 빈 리스트)
    final trades = _tradeData[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Column(
          children: [
            Container(
              color: const Color(0xFF4A68EA),
              height: 60,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "거래 일정 관리",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 달력 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = DateTime(
                        selectedDay.year, selectedDay.month, selectedDay.day);
                    _focusedDay = focusedDay;
                  });
                },
                // 각 날짜에 해당하는 이벤트(Trade)를 반환합니다.
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return _tradeData[key] ?? [];
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                // 달력의 marker를 각 날짜에 있는 거래 데이터로 커스텀 처리 (첫 거래의 isSeller 값을 기준)
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      final trade = events.first as Trade;
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: trade.isSeller
                                ? const Color.fromARGB(255, 226, 141, 88)
                                : const Color.fromARGB(255, 142, 220, 144),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 날짜 헤더와 + 버튼 (날짜 텍스트는 5픽셀 오른쪽 패딩)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "${_selectedDay.year % 100}년 ${_selectedDay.month}월 ${_selectedDay.day}일",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // _isSelectionMode가 활성화되면 '취소' 텍스트 버튼, 아니면 - 아이콘 버튼 표시
                  _isSelectionMode
                      ? TextButton(
                          onPressed: () {
                            // 삭제 모드 취소
                            setState(() {
                              _isSelectionMode = false;
                            });
                          },
                          child: const Text(
                            "취소",
                            style: TextStyle(
                                color: Color.fromARGB(255, 64, 119, 238)),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _isSelectionMode = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("삭제할 거래일정을 선택해주세요.")),
                            );
                          },
                          icon: const Icon(Icons.remove),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // 거래 일정 카드 목록: 한 날짜에 여러 거래가 있으면 거래 개수만큼 표시
            ...trades.map((trade) => _buildTradeCard(trade)).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        onTap: (index) {},
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

  Widget _buildTradeCard(Trade trade) {
    // 기존 카드 위젯
    Widget cardContent = Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 첫 번째 줄: 아이콘 + 날짜/시간 텍스트
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/mypage_images/calendar_icon.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "${trade.tradeDate.year % 100}년 ${trade.tradeDate.month}월 ${trade.tradeDate.day}일 ${trade.time} ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      TextSpan(
                        text: trade.buyerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const TextSpan(
                        text: "님과 거래 약속을 만들었어요",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 두 번째 줄: 위치 아이콘 + 주소
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trade.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616161),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 세 번째 줄: 거래 글 바로가기 + 상품명 (클릭 시 ContentReaderScreen으로 이동)
          InkWell(
            onTap: () async {
              try {
                final postId = trade.postId;
                final response = await dio.get("/api/posts/$postId");
                if (response.statusCode == 200) {
                  final jsonData = response.data;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContentReaderScreen(
                        image: jsonData['image_url'],
                        title: jsonData['title'],
                        location: jsonData['location'],
                        price: jsonData['price'],
                        comments: jsonData['comment_count'],
                        likes: jsonData['like_count'],
                        tagColor: Color(int.parse(
                            jsonData['tagColor'].replaceFirst('#', '0xff'))),
                        username: jsonData['username'],
                        userRegion: jsonData['userRegion'],
                        postId: jsonData['post_id'],
                        postUid: jsonData['uid'],
                        currentUserUid: jsonData['currentUserUid'],
                        content: jsonData['content'],
                        createdAt: jsonData['created_at'],
                        status: jsonData['status'],
                      ),
                    ),
                  );
                } else {
                  print("Failed to load post detail: ${response.statusCode}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("게시글 상세정보를 불러오지 못했습니다.")),
                  );
                }
              } catch (e) {
                print("Error fetching post detail: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("오류가 발생했습니다.")),
                );
              }
            },
            child: Row(
              children: [
                const Text(
                  "거래 글 바로가기 >",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616161),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  trade.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 네 번째 줄: 거래금액과 거래완료 상태 또는 구매확정 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "거래금액 : ${trade.price}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: trade.postStatus == "거래완료"
                      ? Colors.grey
                      : const Color(0xFF212121),
                ),
              ),
              if (trade.postStatus == "거래완료")
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    trade.isSeller ? "판매완료" : "구매완료",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                )
              else if (!trade.isSeller)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 1,
                      side: const BorderSide(
                        color: Color.fromARGB(255, 160, 160, 160),
                        width: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      // 구매확정 버튼 액션
                      confirmPurchase(trade);
                    },
                    child: const Text(
                      "구매확정",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    // 삭제 모드일 경우 카드 전체를 탭할 수 있게 GestureDetector로 래핑하여 삭제 확인 처리
    if (_isSelectionMode) {
      return GestureDetector(
        onTap: () async {
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("삭제 확인"),
                content: const Text("이 거래일정을 삭제하시겠습니까?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("취소"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("삭제"),
                  ),
                ],
              );
            },
          );
          if (confirm == true) {
            deleteTrade(trade);
          }
        },
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: cardContent,
        ),
      );
    } else {
      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: cardContent,
      );
    }
  }
}
