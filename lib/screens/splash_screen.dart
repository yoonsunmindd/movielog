import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';

/// 세션 확인 중/확인 실패를 보여주는 시작 화면. initializing/retryRequired
/// 동안만 보인다(authRedirect가 그 외 상태에서는 다른 경로로 보낸다).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isRetry = authViewModel.status == AuthStatus.retryRequired;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/logos/movielog_logo.svg',
                width: 72,
                height: 72,
              ),
              const SizedBox(height: 24),
              Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              if (isRetry) ...[
                Text(
                  authViewModel.message ?? '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.errorRed,
                  ),
                ),
                const SizedBox(height: 16),
                MovieLogButton(
                  label: '다시 시도',
                  onPressed: () => authViewModel.restoreSession(),
                ),
              ] else
                const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
