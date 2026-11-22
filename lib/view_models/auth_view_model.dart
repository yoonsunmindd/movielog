import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_error.dart';
import '../core/storage/token_storage.dart';
import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/member_api_service.dart';
import 'session_ratings_store.dart';

enum AuthStatus { initializing, signedOut, authenticating, signedIn, retryRequired }

enum MemberLoadStatus { idle, loading, success, error }

/// 로그인 상태, 내 정보, 세션 수명을 관리한다. 평점 데이터 자체는
/// SessionRatingsStore가 들고 있고, 세션이 바뀔 때 이 ViewModel이 비워준다.
class AuthViewModel extends ChangeNotifier {
  final AuthApiService _authApiService;
  final MemberApiService _memberApiService;
  final TokenStorage _tokenStorage;
  final SessionRatingsStore _sessionRatingsStore;

  AuthViewModel(
    this._authApiService,
    this._memberApiService,
    this._tokenStorage,
    this._sessionRatingsStore,
  );

  AuthStatus status = AuthStatus.initializing;
  MemberInfo? member;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  String? message;
  bool sessionExpired = false;
  bool storageCleanupInProgress = false;

  int _sessionVersion = 0;
  int get sessionVersion => _sessionVersion;

  Future<void>? _pendingTokenSave;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool _isCurrent(int version) => !_disposed && version == _sessionVersion;

  Future<void> restoreSession() async {
    final version = _sessionVersion;

    String? token;
    try {
      token = await _tokenStorage.readAccessToken();
    } catch (e) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.retryRequired;
      message = '인증 저장소를 읽지 못했어요. 다시 시도해 주세요.';
      notifyListeners();
      return;
    }

    if (!_isCurrent(version)) return;

    if (token == null) {
      status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }

    try {
      final me = await _memberApiService.fetchMe();
      if (!_isCurrent(version)) return;
      member = me;
      memberStatus = MemberLoadStatus.success;
      status = AuthStatus.signedIn;
      notifyListeners();
    } on DioException catch (e) {
      if (!_isCurrent(version)) return;
      if (isAuthExpiredCode(apiErrorCode(e))) {
        await _clearCurrentSession(expired: true);
      } else {
        status = AuthStatus.retryRequired;
        message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
        notifyListeners();
      }
    } catch (e) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    if (status == AuthStatus.authenticating || storageCleanupInProgress) {
      return;
    }

    final version = ++_sessionVersion;
    _sessionRatingsStore.clear();
    status = AuthStatus.authenticating;
    message = null;
    notifyListeners();

    LoginResult result;
    try {
      result = await _authApiService.login(
        LoginRequest(email: email, password: password),
      );
    } on DioException catch (e) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = apiErrorCode(e) == 'AUTH401_1'
          ? '이메일 또는 비밀번호를 확인해 주세요.'
          : '로그인 요청에 실패했어요. 잠시 후 다시 시도해 주세요.';
      notifyListeners();
      return;
    } catch (e) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = '로그인 요청에 실패했어요. 잠시 후 다시 시도해 주세요.';
      notifyListeners();
      return;
    }

    final saveFuture = _tokenStorage.saveAccessToken(result.accessToken);
    _pendingTokenSave = saveFuture;
    try {
      await saveFuture;
    } catch (e) {
      if (_isCurrent(version)) {
        status = AuthStatus.signedOut;
        message = '로그인 정보를 안전하게 저장하지 못했어요.';
        notifyListeners();
      }
      return;
    } finally {
      if (identical(_pendingTokenSave, saveFuture)) {
        _pendingTokenSave = null;
      }
    }

    if (!_isCurrent(version)) return;
    status = AuthStatus.signedIn;
    notifyListeners();
  }

  /// signedIn일 때만 호출된다. 이미 member가 있으면 force가 아닌 한 다시
  /// 부르지 않는다. 라우터가 signedIn 전환 시점에 한 번 호출해준다.
  Future<void> loadMember({bool force = false}) async {
    if (status != AuthStatus.signedIn) return;
    if (member != null && !force) return;
    if (memberStatus == MemberLoadStatus.loading) return;

    final version = _sessionVersion;
    memberStatus = MemberLoadStatus.loading;
    notifyListeners();

    try {
      final me = await _memberApiService.fetchMe();
      if (!_isCurrent(version)) return;
      member = me;
      memberStatus = MemberLoadStatus.success;
    } on DioException catch (e) {
      if (!_isCurrent(version)) return;
      if (isAuthExpiredCode(apiErrorCode(e))) {
        await _clearCurrentSession(expired: true);
        return;
      }
      memberStatus = MemberLoadStatus.error;
      message = apiErrorMessage(e);
    } catch (e) {
      if (!_isCurrent(version)) return;
      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    }

    if (!_isCurrent(version)) return;
    notifyListeners();
  }

  void updateMember(MemberInfo updated) {
    member = updated;
    notifyListeners();
  }

  /// 401(만료/무효 토큰)을 받은 쪽에서 호출하는 공개 진입점.
  Future<void> expireSession() => _clearCurrentSession(expired: true);

  /// 직접 로그아웃. 만료 안내는 띄우지 않는다.
  Future<void> logout() => _clearCurrentSession(expired: false);

  void consumeSessionExpired() {
    if (sessionExpired) {
      sessionExpired = false;
      notifyListeners();
    }
  }

  /// 동시에 여러 401이 와도 정리/알림은 한 번만 실행된다.
  Future<void> _clearCurrentSession({required bool expired}) async {
    if (storageCleanupInProgress) return;
    storageCleanupInProgress = true;
    _sessionVersion++;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    _sessionRatingsStore.clear();
    notifyListeners();

    final pending = _pendingTokenSave;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {
        // 저장 자체의 실패는 아래 delete 쪽에서 다룬다.
      }
    }

    try {
      await _tokenStorage.deleteAccessToken();
    } catch (e) {
      message = '로그아웃 처리 중 저장소를 정리하지 못했어요.';
    }

    if (expired) sessionExpired = true;
    status = AuthStatus.signedOut;
    storageCleanupInProgress = false;
    if (!_disposed) notifyListeners();
  }
}
