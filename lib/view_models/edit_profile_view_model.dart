import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_error.dart';
import '../data/models/member_info.dart';
import '../data/services/member_api_service.dart';
import 'auth_view_model.dart';

enum EditProfileStatus { idle, saving, success, failure }

class EditProfileViewModel extends ChangeNotifier {
  final MemberApiService _memberApiService;
  final AuthViewModel _authViewModel;
  final MemberInfo initialMember;

  EditProfileViewModel(
    this._memberApiService,
    this._authViewModel,
    this.initialMember,
  );

  EditProfileStatus status = EditProfileStatus.idle;
  String? nicknameError;
  String? message;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> save(String nickname) async {
    if (status == EditProfileStatus.saving) return;

    final trimmed = nickname.trim();
    if (trimmed.length < 2 || trimmed.length > 12) {
      nicknameError = '닉네임은 2~12자로 입력해주세요.';
      status = EditProfileStatus.failure;
      notifyListeners();
      return;
    }

    if (trimmed == initialMember.nickname) {
      status = EditProfileStatus.success;
      notifyListeners();
      return;
    }

    final version = _authViewModel.sessionVersion;
    status = EditProfileStatus.saving;
    nicknameError = null;
    message = null;
    notifyListeners();

    try {
      final updated = await _memberApiService.updateNickname(trimmed);
      if (version != _authViewModel.sessionVersion || _disposed) return;
      _authViewModel.updateMember(updated);
      status = EditProfileStatus.success;
      notifyListeners();
    } on DioException catch (e) {
      if (version != _authViewModel.sessionVersion || _disposed) return;
      final code = apiErrorCode(e);
      status = EditProfileStatus.failure;

      if (isAuthExpiredCode(code)) {
        notifyListeners();
        await _authViewModel.expireSession();
        return;
      } else if (code == 'MEMBER409_1') {
        nicknameError = '이미 사용 중인 닉네임이에요.';
      } else if (code == 'COMMON400') {
        nicknameError = apiErrorMessage(e);
      } else if (code == 'MEMBER404_1') {
        message = '회원 정보를 찾을 수 없어요.';
      } else {
        message = '네트워크 상태를 확인하고 다시 시도해 주세요.';
      }
      notifyListeners();
    } catch (e) {
      if (version != _authViewModel.sessionVersion || _disposed) return;
      status = EditProfileStatus.failure;
      message = '네트워크 상태를 확인하고 다시 시도해 주세요.';
      notifyListeners();
    }
  }
}
