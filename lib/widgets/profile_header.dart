import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 52,
          backgroundImage: AssetImage(
            'assets/images/profile/profile_movielog.jpg',
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 닉네임
        Text(
          '무비러버',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        // 소개 문구
        Text(
          '좋아하는 영화를 기록하고 있어요',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}