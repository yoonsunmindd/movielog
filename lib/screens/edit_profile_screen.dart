import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/movielog_button.dart';

/// EditProfileViewModel은 member가 있어야 만들 수 있어서, 아직 안 채워졌을
/// 때(혹은 실패했을 때) 이 화면을 대신 보여준다.
class EditProfileMemberGate extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;

  const EditProfileMemberGate({
    super.key,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text('프로필 수정', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '내 정보를 불러오지 못했어요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MovieLogButton(label: '다시 시도', onPressed: onRetry),
                ],
              ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nicknameController;
  bool _handledSuccess = false;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<EditProfileViewModel>();
    _nicknameController = TextEditingController(
      text: viewModel.initialMember.nickname,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    context.read<EditProfileViewModel>().save(_nicknameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditProfileViewModel>();
    final isSaving = viewModel.status == EditProfileStatus.saving;
    final signedIn = context.select<AuthViewModel, bool>(
      (auth) => auth.status == AuthStatus.signedIn,
    );

    if (viewModel.status == EditProfileStatus.success && !_handledSuccess) {
      _handledSuccess = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필을 수정했어요.')),
        );
        Navigator.of(context).maybePop();
      });
    } else if (viewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || viewModel.message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.message!)),
        );
      });
    }

    return PopScope(
      canPop: !isSaving,
      child: Scaffold(
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
            onPressed: isSaving ? null : () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            '프로필 수정',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: !signedIn
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이메일 (변경할 수 없습니다)',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        viewModel.initialMember.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '닉네임',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nicknameController,
                      enabled: !isSaving,
                      maxLength: 12,
                      decoration: InputDecoration(
                        errorText: viewModel.nicknameError,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const Spacer(),
                    MovieLogButton(
                      label: '저장',
                      isLoading: isSaving,
                      onPressed: _handleSave,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
