import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_section.dart';
import '../widgets/genre_section.dart';
import '../widgets/app_bar.dart';
import 'sign_up_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MovieLogAppBar(title: '내 프로필'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ProfileHeader(),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('프로필 수정'),
                ),
                const SizedBox(height: 12),

                // TODO: Week 2 회원가입 화면 확인용 임시 버튼 — 확인 후 제거
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text('회원가입 화면 보기 (임시)'),
                ),
                const SizedBox(height: 20),
                
                const StatSection(),
                const SizedBox(height: 32),
                
                const GenreSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}