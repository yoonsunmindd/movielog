import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_ratings_store.dart';

class _FakeTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<void> saveAccessToken(String token) async => this.token = token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async => token = null;
}

Dio _resolvingDio(Map<String, dynamic> data, {int statusCode = 200}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(requestOptions: options, statusCode: statusCode, data: data),
        );
      },
    ),
  );
  return dio;
}

Dio _rejectingDio({String? code, DioExceptionType? type}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (code != null) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                data: {'isSuccess': false, 'code': code, 'message': '실패'},
              ),
            ),
          );
        } else {
          handler.reject(
            DioException(
              requestOptions: options,
              type: type ?? DioExceptionType.connectionError,
            ),
          );
        }
      },
    ),
  );
  return dio;
}

void main() {
  test('로그인 성공 시 토큰을 저장하고 signedIn이 된다', () async {
    final loginDio = _resolvingDio({
      'isSuccess': true,
      'code': 'COMMON200',
      'message': 'ok',
      'result': {'nickname': '닉네임', 'accessToken': 'token-abc'},
    });
    final tokenStorage = _FakeTokenStorage();
    final authViewModel = AuthViewModel(
      AuthApiService(loginDio),
      MemberApiService(Dio()),
      tokenStorage,
      SessionRatingsStore(),
    );

    await authViewModel.login('a@example.com', 'Password123!');

    expect(authViewModel.status, AuthStatus.signedIn);
    expect(tokenStorage.token, 'token-abc');
  });

  test('AUTH401_1은 signedOut + 안내 문구, 토큰은 저장하지 않는다', () async {
    final loginDio = _rejectingDio(code: 'AUTH401_1');
    final tokenStorage = _FakeTokenStorage();
    final authViewModel = AuthViewModel(
      AuthApiService(loginDio),
      MemberApiService(Dio()),
      tokenStorage,
      SessionRatingsStore(),
    );

    await authViewModel.login('a@example.com', 'wrong');

    expect(authViewModel.status, AuthStatus.signedOut);
    expect(authViewModel.message, '이메일 또는 비밀번호를 확인해 주세요.');
    expect(authViewModel.sessionExpired, isFalse);
    expect(tokenStorage.token, isNull);
  });

  test('restoreSession: 토큰이 없으면 signedOut', () async {
    final authViewModel = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(Dio()),
      _FakeTokenStorage(),
      SessionRatingsStore(),
    );

    await authViewModel.restoreSession();

    expect(authViewModel.status, AuthStatus.signedOut);
  });

  test('restoreSession: 토큰이 있고 GET me가 성공하면 signedIn', () async {
    final memberDio = _resolvingDio({
      'isSuccess': true,
      'code': 'COMMON200',
      'message': 'ok',
      'result': {
        'email': 'a@example.com',
        'nickname': '닉네임',
        'createdAt': '2026-01-01T00:00:00.000Z',
      },
    });
    final tokenStorage = _FakeTokenStorage()..token = 'token-abc';
    final authViewModel = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(memberDio),
      tokenStorage,
      SessionRatingsStore(),
    );

    await authViewModel.restoreSession();

    expect(authViewModel.status, AuthStatus.signedIn);
    expect(authViewModel.member?.nickname, '닉네임');
  });

  test('restoreSession: AUTH401_3이면 토큰을 지우고 signedOut + sessionExpired', () async {
    final memberDio = _rejectingDio(code: 'AUTH401_3');
    final tokenStorage = _FakeTokenStorage()..token = 'token-abc';
    final authViewModel = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(memberDio),
      tokenStorage,
      SessionRatingsStore(),
    );

    await authViewModel.restoreSession();

    expect(authViewModel.status, AuthStatus.signedOut);
    expect(authViewModel.sessionExpired, isTrue);
    expect(tokenStorage.token, isNull);
  });

  test('restoreSession: 통신 실패면 retryRequired이고 토큰은 유지한다', () async {
    final memberDio = _rejectingDio(type: DioExceptionType.connectionError);
    final tokenStorage = _FakeTokenStorage()..token = 'token-abc';
    final authViewModel = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(memberDio),
      tokenStorage,
      SessionRatingsStore(),
    );

    await authViewModel.restoreSession();

    expect(authViewModel.status, AuthStatus.retryRequired);
    expect(tokenStorage.token, 'token-abc');
  });

  test('로그아웃 뒤 늦게 도착한 로그인 응답은 무시된다', () async {
    final completer = Completer<Response>();
    final loginDio = Dio();
    loginDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          handler.resolve(await completer.future);
        },
      ),
    );
    final tokenStorage = _FakeTokenStorage();
    final authViewModel = AuthViewModel(
      AuthApiService(loginDio),
      MemberApiService(Dio()),
      tokenStorage,
      SessionRatingsStore(),
    );

    final loginFuture = authViewModel.login('a@example.com', 'Password123!');
    await authViewModel.logout();

    completer.complete(
      Response(
        requestOptions: RequestOptions(path: '/v7/auth/login'),
        statusCode: 200,
        data: {
          'isSuccess': true,
          'code': 'COMMON200',
          'message': 'ok',
          'result': {'nickname': '닉네임', 'accessToken': 'token-abc'},
        },
      ),
    );
    await loginFuture;

    expect(authViewModel.status, AuthStatus.signedOut);
  });

  test('logout은 sessionExpired를 켜지 않는다', () async {
    final authViewModel = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(Dio()),
      _FakeTokenStorage(),
      SessionRatingsStore(),
    );
    authViewModel.status = AuthStatus.signedIn;

    await authViewModel.logout();

    expect(authViewModel.status, AuthStatus.signedOut);
    expect(authViewModel.sessionExpired, isFalse);
  });
}
