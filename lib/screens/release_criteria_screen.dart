import 'package:flutter/material.dart';

class ReleaseCriteriaPage extends StatelessWidget {
  const ReleaseCriteriaPage({super.key});

  // 어종 데이터를 하드코딩 (추후 API 호출로 대체 가능)
  final List<Fish> fishList = const [
    Fish(
      name: '감성돔',
      imagePath: 'assets/images/gamseongdom.jpg',
      category: '어류',
      limit: '금지체장: 25cm 이하',
    ),
    Fish(
      name: '점농어',
      imagePath: 'assets/images/jeomnongeo.jpg',
      category: '어류',
      limit: '금지체장: null',
    ),
    Fish(
      name: '농어',
      imagePath: 'assets/images/nongeo.jpg',
      category: '어류',
      limit: '금지체장: 30cm 이하',
    ),
    Fish(
      name: '새눈치',
      imagePath: 'assets/images/saenunchi.jpg',
      category: '어류',
      limit: '금지체장: null',
    ),
    Fish(
      name: '넙치',
      imagePath: 'assets/images/neobchinongeo.jpg',
      category: '어류',
      limit: '금지체장: 30cm 이하',
    ),
    Fish(
      name: '방어',
      imagePath: 'assets/fishes/bangeo.png',
      category: '어류',
      limit: '금지체장: 30cm 이하',
    ),
    Fish(
      name: '붕장어',
      imagePath: 'assets/fishes/bungjangeo.png',
      category: '어류',
      limit: '금지체장: 35cm 이하',
    ),
    Fish(
      name: '참돔',
      imagePath: 'assets/fishes/chamdom.png',
      category: '어류',
      limit: '금지체장: 24cm 이하',
    ),
    Fish(
      name: '참가자미',
      imagePath: 'assets/fishes/chamgajami.png',
      category: '어류',
      limit: '금지체장: 20cm 이하',
    ),
    Fish(
      name: '대구',
      imagePath: 'assets/fishes/daegu.png',
      category: '어류',
      limit: '금지체장: 35cm 이하',
    ),
    Fish(
      name: '돌돔',
      imagePath: 'assets/fishes/doldom.png',
      category: '어류',
      limit: '금지체장: 24cm 이하',
    ),
    Fish(
      name: '도루묵',
      imagePath: 'assets/fishes/dorumuck.png',
      category: '어류',
      limit: '금지체장: 11cm 이하',
    ),
    Fish(
      name: '개서대',
      imagePath: 'assets/fishes/gaeseodae.png',
      category: '어류',
      limit: '금지체장: 26cm 이하',
    ),
    Fish(
      name: '기름가자미',
      imagePath: 'assets/fishes/gileumgajami.png',
      category: '어류',
      limit: '금지체장: 20cm 이하',
    ),
    Fish(
      name: '민어',
      imagePath: 'assets/fishes/mineo.png',
      category: '어류',
      limit: '금지체장: 33cm 이하',
    ),
    Fish(
      name: '문치가자미',
      imagePath: 'assets/fishes/munchigajami.png',
      category: '어류',
      limit: '금지체장: 20cm 이하',
    ),
    Fish(
      name: '넙치(광어)',
      imagePath: 'assets/fishes/neobchi.png',
      category: '어류',
      limit: '금지체장: 35cm 이하',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경 흰색
        title: const Text(
          '방생기준',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: fishList.length,
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300,
            indent: 8,
            endIndent: 8,
          );
        },
        itemBuilder: (context, index) {
          final fish = fishList[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: Image.asset(
              fish.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            title: Text(
              fish.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fish.category,
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  fish.limit,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Fish {
  final String name;
  final String imagePath;
  final String category;
  final String limit;

  const Fish({
    required this.name,
    required this.imagePath,
    required this.category,
    required this.limit,
  });
}
