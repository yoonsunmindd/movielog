import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/services/member_check_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

/// 회원가입 화면의 닉네임/이메일 중복 확인 상태를 관리한다.
/// 두 필드는 서로 영향이 없게 각각 독립된 필드 세트로 따로 관리한다.
class SignUpViewModel extends ChangeNotifier {
  final MemberCheckService _service;

  SignUpViewModel(this._service);

  CheckStatus nicknameStatus = CheckStatus.idle;
  String? nicknameErrorText;
  String nicknameValue = '';
  String? _lastDuplicateNickname;
  int _nicknameRequestVersion = 0;

  CheckStatus emailStatus = CheckStatus.idle;
  String? emailErrorText;
  String emailValue = '';
  String? _lastDuplicateEmail;
  int _emailRequestVersion = 0;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// 입력이 바뀔 때마다 호출한다. 직전에 중복으로 확인된 값과 같으면 재호출 없이
  /// 바로 duplicated로, 다르면 이전 결과를 무효화(idle)한다.
  void onNicknameChanged(String value) {
    nicknameValue = value;
    if (value.isNotEmpty && value == _lastDuplicateNickname) {
      nicknameStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }
    notifyListeners();
  }

  void onEmailChanged(String value) {
    emailValue = value;
    if (value.isNotEmpty && value == _lastDuplicateEmail) {
      emailStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailStatus = CheckStatus.idle;
      emailErrorText = null;
    }
    notifyListeners();
  }

  Future<void> checkNickname() async {
    if (nicknameStatus == CheckStatus.checking) return;
    final value = nicknameValue.trim();
    if (value.isEmpty) return;

    final version = ++_nicknameRequestVersion;
    nicknameStatus = CheckStatus.checking;
    nicknameErrorText = null;
    notifyListeners();

    try {
      final result = await _service.checkNickname(value);
      if (version != _nicknameRequestVersion || _disposed) return;
      if (result.available) {
        nicknameStatus = CheckStatus.available;
        nicknameErrorText = null;
      } else {
        nicknameStatus = CheckStatus.duplicated;
        nicknameErrorText = '이미 사용 중인 닉네임입니다.';
        _lastDuplicateNickname = value;
      }
    } on DioException {
      if (version != _nicknameRequestVersion || _disposed) return;
      nicknameStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed) notifyListeners();
  }

  Future<void> checkEmail() async {
    if (emailStatus == CheckStatus.checking) return;
    final value = emailValue.trim();
    if (value.isEmpty) return;

    final version = ++_emailRequestVersion;
    emailStatus = CheckStatus.checking;
    emailErrorText = null;
    notifyListeners();

    try {
      final result = await _service.checkEmail(value);
      if (version != _emailRequestVersion || _disposed) return;
      if (result.available) {
        emailStatus = CheckStatus.available;
        emailErrorText = null;
      } else {
        emailStatus = CheckStatus.duplicated;
        emailErrorText = '이미 사용 중인 이메일입니다.';
        _lastDuplicateEmail = value;
      }
    } on DioException {
      if (version != _emailRequestVersion || _disposed) return;
      emailStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed) notifyListeners();
  }
}
