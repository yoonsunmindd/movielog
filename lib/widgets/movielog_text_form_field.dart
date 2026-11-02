import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// 회원가입 화면의 입력창들이 공통으로 쓰는 스타일/보더/검증 아이콘 로직을 담은
/// 재사용 가능한 TextFormField.
class MovieLogTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? errorText;
  final bool isValid;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final String? Function(String?) validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final VoidCallback? onToggleObscureText;

  const MovieLogTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.validator,
    this.errorText,
    this.isValid = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.onToggleObscureText,
  });

  bool get _hasError => errorText != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary),
            errorText: errorText,
            filled: true,
            fillColor: _hasError
                ? AppColors.errorRed.withValues(alpha: 0.12)
                : AppColors.surface,
            suffixIcon: _buildSuffixIcon(colorScheme),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
            ),
            errorStyle: const TextStyle(color: AppColors.errorRed),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    final icons = <Widget>[];

    if (_hasError) {
      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SvgPicture.asset(
            'assets/icons/error.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.errorRed,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    } else if (isValid) {
      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SvgPicture.asset(
            'assets/icons/check_circle.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
          ),
        ),
      );
    }

    if (onToggleObscureText != null) {
      icons.add(
        IconButton(
          icon: SvgPicture.asset(
            obscureText
                ? 'assets/icons/visibility_off.svg'
                : 'assets/icons/visibility.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.textTertiary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: onToggleObscureText,
        ),
      );
    }

    if (icons.isEmpty) return null;
    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }
}
