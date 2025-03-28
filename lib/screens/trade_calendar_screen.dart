import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TradeCalendarScreen extends StatefulWidget {
  const TradeCalendarScreen({Key? key}) : super(key: key);

  @override
  State<TradeCalendarScreen> createState() => _TradeCalendarScreenState();
}

class _TradeCalendarScreenState extends State<TradeCalendarScreen> {
  // 달력에서 현재 포커스된 날짜
  DateTime _focusedDay = DateTime(2025, 2, 17);
  // 선택된 날짜
  DateTime _selectedDay = DateTime(2025, 2, 17);

  // 예시용 거래 일정 데이터 (날짜별)
  final Map<DateTime, List<Map<String, String>>> _tradeData = {
    DateTime(2025, 2, 17): [
      {
        "time": "19시 00분",
        "address": "사방동 39-19 (월싱컴 앞)",
        "title": "농어 팝니다",
        "price": "20,000원",
      },
      {
        "time": "18시 00분",
        "address": "창원대학교 20 (정문 앞)",
        "title": "감성동 팝니다",
        "price": "45,000원",
      },
    ],
    // 다른 날짜 일정이 있다면 추가
  };

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 날짜의 거래 목록 (없으면 빈 리스트)
    final trades = _tradeData[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
            Image.asset('assets/icons/fish_icon1.png', height: 24),
            const SizedBox(width: 10),
            const Text(
              "거래 일정 관리",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
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
                // 초기 선택 날짜
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                // 월 달력 표시
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                // 캘린더 스타일
                calendarStyle: const CalendarStyle(
                  // 오늘 날짜 스타일
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  // 선택된 날짜 스타일
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
              ),
            ),

            const SizedBox(height: 10),
            // 날짜 헤더 (예: 25년 2월 17일)
            // 원하는 포맷으로 표기해도 됨
            Text(
              "${_selectedDay.year % 100}년 ${_selectedDay.month}월 ${_selectedDay.day}일",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 거래 일정 목록
            const SizedBox(height: 10),
            ...trades.map((trade) => _buildTradeCard(trade)).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: 4, // 원하는 인덱스로 설정
        onTap: (index) {
          // TODO: 원하는 화면으로 이동하는 로직 작성
          // 예: if (index == 0) { ... }
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

  // 거래 일정 카드를 만들어주는 위젯
  Widget _buildTradeCard(Map<String, String> trade) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          // 내용이 길어질 때 세로 정렬
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 아이콘
            Image.asset(
              'assets/mypage_images/calendar_icon.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            // 중간 (일정 정보)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 예: "25년 2월 17일 19시 00분 거래 약속을 만들었어요"
                  Text(
                    "${_selectedDay.year % 100}년 ${_selectedDay.month}월 ${_selectedDay.day}일 ${trade["time"]} 거래 약속을 만들었어요",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trade["address"] ?? "",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 오른쪽 (판매 정보)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  trade["title"] ?? "",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  trade["price"] ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
