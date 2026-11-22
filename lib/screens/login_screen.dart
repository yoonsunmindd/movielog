import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/movielog_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  final bool justSignedUp;

  const LoginScreen({super.key, this.justSignedUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = context.read<AuthViewModel>();
    _authViewModel.addListener(_handleAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.justSignedUp && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료됐어요. 로그인해 주세요.')),
        );
      }
      _maybeShowExpiredSnackbar();
    });
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_handleAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthChanged() => _maybeShowExpiredSnackbar();

  void _maybeShowExpiredSnackbar() {
    if (!mounted || !_authViewModel.sessionExpired) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')),
    );
    _authViewModel.consumeSessionExpired();
  }

  void _handleLogin() {
    _authViewModel.login(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isBusy =
        authViewModel.status == AuthStatus.authenticating ||
        authViewModel.storageCleanupInProgress;
    final loginErrorText = authViewModel.status == AuthStatus.signedOut
        ? authViewModel.message
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('로그인', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: IgnorePointer(
              ignoring: isBusy,
              child: Opacity(
                opacity: isBusy ? 0.6 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/logos/movielog_logo.svg',
                        width: 56,
                        height: 56,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'MovieLog에 로그인',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 32),
                    MovieLogTextFormField(
                      controller: _emailController,
                      label: '이메일',
                      hintText: 'movie@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 16),
                    MovieLogTextFormField(
                      controller: _passwordController,
                      label: '비밀번호',
                      hintText: '비밀번호를 입력해주세요',
                      obscureText: true,
                      errorText: loginErrorText,
                      textInputAction: TextInputAction.done,
                      validator: (_) => null,
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 24),
                    MovieLogButton(
                      label: '로그인',
                      isLoading: authViewModel.status == AuthStatus.authenticating,
                      onPressed: _handleLogin,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '계정이 없나요? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.push('/signup'),
                          child: Text(
                            '회원가입',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
