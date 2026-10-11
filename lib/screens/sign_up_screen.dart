import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
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

  bool get _isNicknameValid =>
      Validators.nickname(_nicknameController.text) == null;
  bool get _isEmailValid => Validators.email(_emailController.text) == null;
  bool get _isPasswordValid =>
      Validators.password(_passwordController.text) == null;

  bool get _isSubmitEnabled =>
      _isNicknameValid && _isEmailValid && _isPasswordValid && _agreedToTerms;

  void _handleSubmit() {
    setState(() {
      _nicknameTouched = true;
      _emailTouched = true;
      _passwordTouched = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();

    if (isValid && _agreedToTerms) {
      // Mock 회원가입: 실제 API 연동 없이 홈으로 이동.
      // go()를 사용해 스택을 교체하므로 홈 화면에서 시스템 뒤로가기로
      // 회원가입 화면으로 돌아갈 수 없다.
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          nicknameErrorText: _nicknameTouched
                              ? Validators.nickname(_nicknameController.text)
                              : null,
                          emailErrorText: _emailTouched
                              ? Validators.email(_emailController.text)
                              : null,
                          passwordErrorText: _passwordTouched
                              ? Validators.password(_passwordController.text)
                              : null,
                          isNicknameValid: _nicknameTouched && _isNicknameValid,
                          isEmailValid: _emailTouched && _isEmailValid,
                          isPasswordValid: _passwordTouched && _isPasswordValid,
                          obscurePassword: _obscurePassword,
                          onNicknameChanged: (value) => setState(
                            () => _nicknameTouched = true,
                          ),
                          onEmailChanged: (value) =>
                              setState(() => _emailTouched = true),
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
                          isSubmitEnabled: _isSubmitEnabled,
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
