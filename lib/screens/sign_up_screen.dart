import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/sign_up_header.dart';
import '../widgets/sign_up_form_section.dart';
import '../widgets/terms_and_submit_section.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  bool _nicknameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool get _isNicknameFormatValid =>
      Validators.nickname(_nicknameController.text) == null;
  bool get _isEmailFormatValid =>
      Validators.email(_emailController.text) == null;
  bool get _isPasswordValid =>
      Validators.password(_passwordController.text) == null;

  bool _isSubmitEnabled(SignUpViewModel viewModel) =>
      _isNicknameFormatValid &&
      _isEmailFormatValid &&
      _isPasswordValid &&
      _agreedToTerms &&
      viewModel.nicknameStatus == CheckStatus.available &&
      viewModel.emailStatus == CheckStatus.available;

  void _handleSubmit() {
    setState(() {
      _nicknameTouched = true;
      _emailTouched = true;
      _passwordTouched = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();

    if (isValid && _isSubmitEnabled(context.read<SignUpViewModel>())) {
      // Mock 회원가입: 실제 API 연동 없이 홈으로 이동.
      // go()를 사용해 스택을 교체하므로 홈 화면에서 시스템 뒤로가기로
      // 회원가입 화면으로 돌아갈 수 없다.
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    final nicknameFormatError = _nicknameTouched
        ? Validators.nickname(_nicknameController.text)
        : null;
    final emailFormatError = _emailTouched
        ? Validators.email(_emailController.text)
        : null;

    final nicknameErrorText =
        nicknameFormatError ??
        (viewModel.nicknameStatus == CheckStatus.duplicated ||
                viewModel.nicknameStatus == CheckStatus.error
            ? viewModel.nicknameErrorText
            : null);
    final emailErrorText =
        emailFormatError ??
        (viewModel.emailStatus == CheckStatus.duplicated ||
                viewModel.emailStatus == CheckStatus.error
            ? viewModel.emailErrorText
            : null);

    final nicknameHelperText = nicknameFormatError != null
        ? null
        : switch (viewModel.nicknameStatus) {
            CheckStatus.checking => '닉네임 사용 가능 여부를 확인 중입니다.',
            CheckStatus.available => '사용 가능한 닉네임입니다.',
            _ => null,
          };
    final emailHelperText = emailFormatError != null
        ? null
        : switch (viewModel.emailStatus) {
            CheckStatus.checking => '이메일 사용 가능 여부를 확인 중입니다.',
            CheckStatus.available => '사용 가능한 이메일입니다.',
            _ => null,
          };

    final isNicknameValid =
        nicknameFormatError == null &&
        viewModel.nicknameStatus == CheckStatus.available;
    final isEmailValid =
        emailFormatError == null &&
        viewModel.emailStatus == CheckStatus.available;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            colorFilter: const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('회원가입', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 700;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 560 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SignUpHeader(),
                        const SizedBox(height: 32),
                        SignUpFormSection(
                          nicknameController: _nicknameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          nicknameErrorText: nicknameErrorText,
                          emailErrorText: emailErrorText,
                          passwordErrorText: _passwordTouched
                              ? Validators.password(_passwordController.text)
                              : null,
                          isNicknameValid: isNicknameValid,
                          isEmailValid: isEmailValid,
                          isPasswordValid: _passwordTouched && _isPasswordValid,
                          nicknameHelperText: nicknameHelperText,
                          nicknameHelperColor:
                              viewModel.nicknameStatus == CheckStatus.checking
                              ? Colors.blue
                              : AppColors.successGreen,
                          emailHelperText: emailHelperText,
                          emailHelperColor:
                              viewModel.emailStatus == CheckStatus.checking
                              ? Colors.blue
                              : AppColors.successGreen,
                          isNicknameChecking:
                              viewModel.nicknameStatus == CheckStatus.checking,
                          isEmailChecking:
                              viewModel.emailStatus == CheckStatus.checking,
                          onCheckNickname:
                              nicknameFormatError == null &&
                                  viewModel.nicknameStatus !=
                                      CheckStatus.checking
                              ? viewModel.checkNickname
                              : null,
                          onCheckEmail:
                              emailFormatError == null &&
                                  viewModel.emailStatus != CheckStatus.checking
                              ? viewModel.checkEmail
                              : null,
                          obscurePassword: _obscurePassword,
                          onNicknameChanged: (value) {
                            setState(() => _nicknameTouched = true);
                            viewModel.onNicknameChanged(value);
                          },
                          onEmailChanged: (value) {
                            setState(() => _emailTouched = true);
                            viewModel.onEmailChanged(value);
                          },
                          onPasswordChanged: (value) =>
                              setState(() => _passwordTouched = true),
                          onTogglePasswordVisibility: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onSubmit: _handleSubmit,
                          nicknameValidator: (value) =>
                              Validators.nickname(value ?? ''),
                          emailValidator: (value) =>
                              Validators.email(value ?? ''),
                          passwordValidator: (value) =>
                              Validators.password(value ?? ''),
                        ),
                        const SizedBox(height: 28),
                        TermsAndSubmitSection(
                          agreedToTerms: _agreedToTerms,
                          onAgreedToTermsChanged: (value) =>
                              setState(() => _agreedToTerms = value),
                          isSubmitEnabled: _isSubmitEnabled(viewModel),
                          onSubmit: _handleSubmit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
