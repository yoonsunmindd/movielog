import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String? nickname;
  final String? email;

  const ProfileHeader({super.key, this.nickname, this.email});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // 프로필 이미지 (Figma 예시 그대로 고정)
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
          nickname ?? '불러오는 중...',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        if (email != null)
          Text(email!, style: textTheme.bodyMedium)
        else
          // 소개 문구 (Figma 예시 그대로 고정)
          Text(
            '좋아하는 영화를 기록하고 있어요',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
      ],
    );
  }
}