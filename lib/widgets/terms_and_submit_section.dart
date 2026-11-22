import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'movielog_button.dart';

/// 약관 동의 체크박스 + 가입 버튼 + 로그인 안내 문구 섹션.
class TermsAndSubmitSection extends StatelessWidget {
  final bool agreedToTerms;
  final ValueChanged<bool> onAgreedToTermsChanged;
  final bool isSubmitEnabled;
  final VoidCallback onSubmit;

  const TermsAndSubmitSection({
    super.key,
    required this.agreedToTerms,
    required this.onAgreedToTermsChanged,
    required this.isSubmitEnabled,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: agreedToTerms,
                activeColor: colorScheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (checked) =>
                    onAgreedToTermsChanged(checked ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => onAgreedToTermsChanged(!agreedToTerms),
                child: Text('필수 약관에 동의합니다', style: textTheme.bodyLarge),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        MovieLogButton(
          label: '가입하기',
          onPressed: isSubmitEnabled ? onSubmit : null,
          width: double.infinity,
          disabledBackgroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.primary,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('이미 계정이 있나요? ', style: textTheme.bodyMedium),
            GestureDetector(
              onTap: () {
                // TODO: 로그인 화면 연결
              },
              child: Text(
                '로그인',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
