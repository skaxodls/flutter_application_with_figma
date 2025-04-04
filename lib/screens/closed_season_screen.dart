import 'package:flutter/material.dart';

class ClosedSeasonScreen extends StatelessWidget {
  const ClosedSeasonScreen({Key? key}) : super(key: key);

  // 5월 금어기 적용 어종 리스트 (예시)
  final List<Fish> bannedFishList = const [
    Fish(
      name: '감성돔',
      imagePath: 'assets/images/gamseongdom.jpg',
      period: '05.01 ~ 05.31',
      description: '금지체장 : 25cm 이하',
    ),
    Fish(
      name: '삼치',
      imagePath: 'assets/fishes/samchi.png',
      period: '05.01 ~ 05.31',
      description: '',
    ),
    Fish(
      name: '말쥐치',
      imagePath: 'assets/fishes/maljwichi.png',
      period: '05.01 ~ 07.31',
      description: '금지체장 : 18cm 이하',
    ),
    Fish(
      name: '코끼리조개(완화)',
      imagePath: 'assets/fishes/kokkilijogae.png',
      period: '05.01 ~ 06.30',
      description: '강원, 경북',
    ),
    Fish(
      name: '쭈꾸미',
      imagePath: 'assets/fishes/jjukkumi.png',
      period: '05.11 ~ 08.31',
      description: '',
    ),
    Fish(
      name: '전어',
      imagePath: 'assets/fishes/jeoneo.png',
      period: '05.01 ~ 07.15',
      description: '단, 강원, 경북 제외',
    ),
    Fish(
      name: '참문어',
      imagePath: 'assets/fishes/chammuneo.png',
      period: '05.16 ~ 06.30',
      description: '시·도지사는 5.1~9.15 중 46일 이상 지정 가능',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바: 왼쪽 뒤로가기 아이콘, 왼쪽 정렬된 작은 제목
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '금어기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      // ListView.builder를 사용하여 헤더, 어종 리스트, 하단 이미지 모두 스크롤 가능하도록 구성
      body: ListView.builder(
        itemCount: bannedFishList.length + 2, // 헤더와 마지막에 agency 이미지 추가
        itemBuilder: (context, index) {
          if (index == 0) {
            // 스크롤 영역 상단의 헤더: 큰 제목과 날짜
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '5월의 금어기',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '23.11.07',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (index == bannedFishList.length + 1) {
            // 스크롤 영역 하단에 agency.png 이미지 (화면 너비에 맞게)
            return Image.asset(
              'assets/images/agency.png',
              width: double.infinity,
              fit: BoxFit.cover,
            );
          } else {
            // 어종 리스트 항목 (index-1 적용)
            final fish = bannedFishList[index - 1];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 물고기 이미지 (중앙 정렬)
                  Center(
                    child: Image.asset(
                      fish.imagePath,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 물고기 이름
                  Text(
                    fish.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 기간
                  Text(
                    '기간 : ${fish.period}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 상세 설명
                  Text(
                    fish.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 구분선
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// 기존 Fish 모델 (period: 기간, description: 상세 설명)
class Fish {
  final String name;
  final String imagePath;
  final String period;
  final String description;

  const Fish({
    required this.name,
    required this.imagePath,
    required this.period,
    required this.description,
  });
}
