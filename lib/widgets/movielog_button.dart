import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 앱 전역에서 쓰는 기본 버튼. 로딩 중에는 라벨 없이 스피너만 보여준다.
class MovieLogButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final double? width;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;

  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    this.disabledBackgroundColor = AppColors.border,
    this.disabledForegroundColor = AppColors.textTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? AppColors.primaryLight : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.primary : Colors.white,
          disabledBackgroundColor: isLoading
              ? AppColors.textSecondary
              : disabledBackgroundColor,
          disabledForegroundColor: isLoading
              ? Colors.white
              : disabledForegroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}
