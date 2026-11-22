import 'package:flutter/material.dart';
import 'movielog_button.dart';
import 'movielog_text_form_field.dart';

/// 닉네임 / 이메일 / 비밀번호 입력창을 한데 묶은 섹션.
class SignUpFormSection extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  final String? nicknameErrorText;
  final String? emailErrorText;
  final String? passwordErrorText;

  final bool isNicknameValid;
  final bool isEmailValid;
  final bool isPasswordValid;

  final String? nicknameHelperText;
  final Color? nicknameHelperColor;
  final String? emailHelperText;
  final Color? emailHelperColor;

  final bool isNicknameChecking;
  final bool isEmailChecking;
  final VoidCallback? onCheckNickname;
  final VoidCallback? onCheckEmail;

  final bool obscurePassword;

  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onSubmit;

  final String? Function(String?) nicknameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;

  const SignUpFormSection({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.nicknameErrorText,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.isNicknameValid,
    required this.isEmailValid,
    required this.isPasswordValid,
    required this.nicknameHelperText,
    required this.nicknameHelperColor,
    required this.emailHelperText,
    required this.emailHelperColor,
    required this.isNicknameChecking,
    required this.isEmailChecking,
    required this.onCheckNickname,
    required this.onCheckEmail,
    required this.obscurePassword,
    required this.onNicknameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    required this.nicknameValidator,
    required this.emailValidator,
    required this.passwordValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '닉네임',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MovieLogTextFormField(
                controller: nicknameController,
                hintText: '닉네임을 입력해주세요',
                errorText: nicknameErrorText,
                helperText: nicknameHelperText,
                helperColor: nicknameHelperColor,
                isValid: isNicknameValid,
                textInputAction: TextInputAction.next,
                validator: nicknameValidator,
                onChanged: onNicknameChanged,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(emailFocusNode),
              ),
            ),
            const SizedBox(width: 8),
            MovieLogButton(
              label: '중복 확인',
              isLoading: isNicknameChecking,
              onPressed: onCheckNickname,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '이메일',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MovieLogTextFormField(
                controller: emailController,
                hintText: '이메일 주소를 입력해주세요',
                errorText: emailErrorText,
                helperText: emailHelperText,
                helperColor: emailHelperColor,
                isValid: isEmailValid,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                focusNode: emailFocusNode,
                validator: emailValidator,
                onChanged: onEmailChanged,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(passwordFocusNode),
              ),
            ),
            const SizedBox(width: 8),
            MovieLogButton(
              label: '중복 확인',
              isLoading: isEmailChecking,
              onPressed: onCheckEmail,
            ),
          ],
        ),
        const SizedBox(height: 16),
        MovieLogTextFormField(
          controller: passwordController,
          label: '비밀번호',
          hintText: '비밀번호를 입력해주세요',
          errorText: passwordErrorText,
          isValid: isPasswordValid,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          focusNode: passwordFocusNode,
          validator: passwordValidator,
          onChanged: onPasswordChanged,
          onFieldSubmitted: (_) => onSubmit(),
          onToggleObscureText: onTogglePasswordVisibility,
        ),
      ],
    );
  }
}
