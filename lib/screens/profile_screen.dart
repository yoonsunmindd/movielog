import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_section.dart';
import '../widgets/genre_section.dart';
import '../widgets/app_bar.dart';
import '../widgets/movielog_bottom_nav_bar.dart';

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
                
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('프로필 수정'),
                ),
                const SizedBox(height: 32),

                const StatSection(),
                const SizedBox(height: 32),
                
                const GenreSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MovieLogBottomNavBar(currentIndex: 2),
    );
  }
}