import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'loading_screen.dart'; // ✅ LoadingScreen 추가
import 'home_screen.dart'; // ✅ 홈 화면 추가
import 'community_screen.dart'; // ✅ 커뮤니티 화면 추가
import 'market_price_screen.dart'; // ✅ 싯가 화면 추가
import 'mypage_screen.dart';
import 'package:flutter_application_with_figma/screens/mypagelogin_screen.dart';
import 'package:flutter_application_with_figma/screens/my_point_screen.dart';
import 'package:flutter_application_with_figma/dio_setup.dart'; // dio 인스턴스 import
import 'package:shared_preferences/shared_preferences.dart';

class SelectPhotoScreen extends StatefulWidget {
  const SelectPhotoScreen({super.key});

  @override
  _SelectPhotoScreenState createState() => _SelectPhotoScreenState();
}

class _SelectPhotoScreenState extends State<SelectPhotoScreen> {
  final List<File> _selectedImages = [];
  File? _selectedImage; // ✅ 선택된 이미지

  @override
  void initState() {
    super.initState();
    _fetchUidAndCheckTip();
  }

  Future<void> _fetchUidAndCheckTip() async {
    try {
      final response = await dio.get('/api/user_profile');
      if (response.statusCode == 200) {
        final uid = response.data['uid'].toString(); // ⚠️ int면 문자열로 변환
        _checkAndShowTipDialog(uid);
      }
    } catch (e) {
      print('사용자 정보 불러오기 실패: $e');
    }
  }

  Future<void> _checkAndShowTipDialog(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTip = prefs.getBool('hasSeenPhotoTip_$uid') ?? false;

    if (!hasSeenTip) {
      await Future.delayed(Duration.zero);
      _showTipDialog(uid);
    }
  }

  void _showTipDialog(String uid) {
    bool _doNotShowAgain = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/goodExample.png'),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip. 물고기 형질이 잘 보이도록 촬영 시\n정확도가 올라갑니다!',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _doNotShowAgain,
                              onChanged: (value) {
                                setState(() {
                                  _doNotShowAgain = value!;
                                });
                              },
                            ),
                            const Text("다시 보지 않기"),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_doNotShowAgain) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool(
                                  'hasSeenPhotoTip_$uid', true); // ✅ 사용자별 저장
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5ED4F4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("확인",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ✅ 갤러리에서 사진 가져오기
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // ✅ 선택한 이미지 저장
  void _selectImage(File image) {
    setState(() {
      if (_selectedImage == image) {
        _selectedImage = null; // 이미 선택된 경우 선택 해제
      } else {
        _selectedImage = image; // 새로운 이미지 선택
      }
    });
  }

  // ✅ 선택한 이미지가 있을 경우, 다음 화면으로 이동
  void _onSelectImage() {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoadingScreen(
                  selectedImage: _selectedImage!,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
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
      body: Column(
        children: [
          const SizedBox(height: 12),

          // 📷 촬영 & 가져오기 버튼 (좌측 정렬)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  _PhotoButton(
                    icon: Icons.photo_camera,
                    label: "카메라",
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 8),
                  _PhotoButton(
                    icon: Icons.add,
                    label: "가져오기",
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🔵 선택하기 버튼 (우측 정렬)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5ED4F4), // 버튼 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _onSelectImage, // ✅ 선택하기 버튼 클릭 시 이동
                child: const Text(
                  "선택하기",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🖼 선택된 사진 표시 (그리드 뷰)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  final image = _selectedImages[index];
                  final isSelected = _selectedImage == image;

                  return GestureDetector(
                    onTap: () => _selectImage(image),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 3,
                        ), // ✅ 선택된 경우 파란색 테두리 추가
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // 🟡 하단 네비게이션 바 (✅ 정상 작동하도록 수정)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF999999), // 비활성화 아이콘 색상 적용
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // ✅ 현재 선택된 탭 (홈)
        onTap: (index) async {
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
                      const CommunityScreen()), // ✅ 커뮤니티 화면 이동
            );
          } else if (index == 2) {
            // 내 포인트 버튼 클릭 시
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPointScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MarketPriceScreen()), // ✅ 싯가 화면 이동
            );
          } else if (index == 4) {
            // ✅ 마이페이지 클릭 시 세션 상태 확인 후 분기
            try {
              final response = await dio.get('/api/check_session');
              final loggedIn = response.statusCode == 200 &&
                  response.data['logged_in'] == true;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => loggedIn
                      ? const MyPageLoginScreen()
                      : const MyPageScreen(),
                ),
              );
            } catch (e) {
              // 오류 발생 시 기본 마이페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPageScreen()),
              );
            }
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

// 📸 사진 선택 버튼 위젯
class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // ✅ 버튼 크기 조정
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
