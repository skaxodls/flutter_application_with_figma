import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_with_figma/dio_setup.dart';

class WriteScreen extends StatefulWidget {
  final int? postId; // 🔸 null이면 새글, 있으면 수정 모드
  final Map<String, dynamic>? initialData;

  const WriteScreen({super.key, this.postId, this.initialData});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  final List<String> _statuses = ['판매중', '예약중', '거래완료'];
  String _selectedStatus = '판매중';

  bool get isEditMode => widget.postId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode && widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _priceController.text = widget.initialData!['price'].toString();
      _contentController.text = widget.initialData!['content'] ?? '';
      _selectedStatus = widget.initialData!['status'] ?? '판매중';
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> submitPost() async {
    final title = _titleController.text;
    final price = int.tryParse(_priceController.text) ?? 0;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 설명을 입력해주세요.')),
      );
      return;
    }

    try {
      if (isEditMode) {
        // 🔁 수정 API (JSON 전송)
        final response = await dio.put(
          '/api/posts/${widget.postId}',
          data: {
            'title': title,
            'price': price,
            'content': content,
            'status': _selectedStatus,
          },
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글이 수정되었습니다.')),
          );
          Navigator.pop(context);
        } else {
          throw Exception('수정 실패');
        }
      } else {
        // 🆕 새글 작성 (multipart/form-data)
        final formData = FormData.fromMap({
          'title': title,
          'price': price.toString(),
          'content': content,
          'status': _selectedStatus,
          if (_selectedImage != null)
            'images': await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: _selectedImage!.name,
            ),
        });

        final response = await dio.post(
          '/api/posts',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

        // await dio.put(
        //   '/api/posts/${widget.postId}',
        //   data: formData,
        //   options: Options(contentType: 'multipart/form-data'),
        // );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글이 등록되었습니다.')),
          );
          Navigator.pop(context);
        } else {
          throw Exception('작성 실패');
        }
      }
    } catch (e) {
      print('에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('게시글 ${isEditMode ? '수정' : '작성'} 중 오류가 발생했습니다.')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? "게시글 수정" : "내 물고기 팔기",
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("사진 (1장 업로드 가능)"),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_selectedImage != null)
                  Image.file(
                    File(_selectedImage!.path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(left: 8),
                    color: Colors.grey[300],
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("제목"),
            const SizedBox(height: 8),
            _CustomTextField(
                controller: _titleController, hintText: "제목을 입력하세요"),
            const SizedBox(height: 16),
            const Text("가격"),
            const SizedBox(height: 8),
            _CustomTextField(
              controller: _priceController,
              hintText: "가격을 입력하세요",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text("설명"),
            const SizedBox(height: 8),
            _CustomTextField(
              controller: _contentController,
              hintText: "설명을 입력하세요",
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const Text("상태"),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCDCDCD)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A68EA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEditMode ? "수정 완료" : "작성 완료",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCDCDCD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A68EA)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
