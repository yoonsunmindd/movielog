import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_section.dart';
import '../widgets/genre_section.dart';
import '../widgets/app_bar.dart';
import '../widgets/movielog_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthViewModel>().member;

    return Scaffold(
      appBar: MovieLogAppBar(
        title: '내 프로필',
        actions: [
          TextButton(
            onPressed: () => context.read<AuthViewModel>().logout(),
            child: const Text('로그아웃'),
          ),
        ],
      ),
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
                ProfileHeader(nickname: member?.nickname, email: member?.email),
                const SizedBox(height: 32),

                OutlinedButton(
                  onPressed: member == null
                      ? null
                      : () => context.push('/my/profile/edit'),
                  child: const Text('프로필 수정'),
                ),
                const SizedBox(height: 32),

                const StatSection(),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/my/ratings'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '내가 등록한 평점',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
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
