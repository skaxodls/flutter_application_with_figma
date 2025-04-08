import 'package:flutter/material.dart';

class TACScreen extends StatelessWidget {
  const TACScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '총허용어획량제도',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF4F5F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/TAC.png'),
            const SizedBox(height: 10),
            Image.asset('assets/images/TAC2013.jpg'),
            const SizedBox(height: 10),
            Image.asset('assets/images/TAC2021.jpg'),
            const SizedBox(height: 10),
            Image.asset('assets/images/TAC2023.jpg'),
            const SizedBox(height: 10),
            Image.asset('assets/images/TAC2024.jpg'),
          ],
        ),
      ),
    );
  }
}
