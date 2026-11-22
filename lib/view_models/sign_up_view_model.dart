import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_error.dart';
import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';
import 'submit_status.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

/// 회원가입 화면의 닉네임/이메일 중복 확인과 제출 상태를 관리한다.
/// 닉네임/이메일은 서로 영향이 없게 각각 독립된 필드 세트로 따로 관리한다.
class SignUpViewModel extends ChangeNotifier {
  final SignUpService _service;

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

  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId;
  String? passwordErrorText;
  String? snackbarMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// 입력이 바뀔 때마다 호출한다. 직전에 중복으로 확인된 값과 같으면 재호출 없이
  /// 바로 duplicated로, 다르면 이전 결과를 무효화(idle)한다. 서버에서 받은
  /// 제출 오류(스낵바)도 더 이상 맞지 않는 값이 될 수 있어 함께 무효화한다.
  void onNicknameChanged(String value) {
    nicknameValue = value;
    if (value.isNotEmpty && value == _lastDuplicateNickname) {
      nicknameStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }
    _clearSubmitError();
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
    _clearSubmitError();
    notifyListeners();
  }

  /// 비밀번호가 바뀌면 서버가 돌려준 비밀번호 오류 문구를 지운다.
  void onPasswordChanged(String value) {
    if (passwordErrorText != null) {
      passwordErrorText = null;
      notifyListeners();
    }
  }

  void _clearSubmitError() {
    if (submitStatus == SubmitStatus.error) {
      submitStatus = SubmitStatus.idle;
    }
    snackbarMessage = null;
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

  Future<void> submit(CreateMemberRequest request) async {
    if (submitStatus == SubmitStatus.submitting) return;

    submitStatus = SubmitStatus.submitting;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();

    try {
      final response = await _service.signUp(request);
      final memberId = response.result?.memberId;
      if (memberId == null) {
        throw StateError('회원가입 응답에 memberId가 없습니다.');
      }
      createdMemberId = memberId;
      submitStatus = SubmitStatus.success;
    } on DioException catch (e) {
      submitStatus = SubmitStatus.error;
      final message = apiErrorMessage(e);
      if (e.response?.statusCode == 400 && message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        snackbarMessage = message;
      }
    } catch (e) {
      submitStatus = SubmitStatus.error;
      snackbarMessage = '회원가입에 실패했어요. 다시 시도해 주세요.';
    }

    if (!_disposed) notifyListeners();
  }
}
