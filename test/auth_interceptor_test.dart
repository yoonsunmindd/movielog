import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/auth_interceptor.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/core/storage/token_storage.dart';

class _FakeTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<void> saveAccessToken(String token) async => this.token = token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async => token = null;
}

class _ThrowingTokenStorage implements TokenStorage {
  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<String?> readAccessToken() async => throw Exception('읽기 실패');

  @override
  Future<void> deleteAccessToken() async {}
}

Future<Map<String, dynamic>> _sendAndCaptureHeaders(
  TokenStorage storage,
  String method,
  String path, {
  String baseUrl = movieLogBaseUrl,
}) async {
  late Map<String, dynamic> captured;
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.interceptors.add(AuthInterceptor(storage));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        captured = Map.of(options.headers);
        handler.resolve(Response(requestOptions: options, statusCode: 200));
      },
    ),
  );
  await dio.request(path, options: Options(method: method));
  return captured;
}

void main() {
  test('보호 경로(GET /v7/members/me)에는 Bearer가 붙는다', () async {
    final storage = _FakeTokenStorage()..token = 'secret-token';
    final headers = await _sendAndCaptureHeaders(storage, 'GET', '/v7/members/me');
    expect(headers['Authorization'], 'Bearer secret-token');
  });

  test('보호 경로(POST /v7/ratings)에는 Bearer가 붙는다', () async {
    final storage = _FakeTokenStorage()..token = 'secret-token';
    final headers = await _sendAndCaptureHeaders(storage, 'POST', '/v7/ratings');
    expect(headers['Authorization'], 'Bearer secret-token');
  });

  test('보호 경로(PATCH /v7/ratings/5)에는 Bearer가 붙는다', () async {
    final storage = _FakeTokenStorage()..token = 'secret-token';
    final headers = await _sendAndCaptureHeaders(
      storage,
      'PATCH',
      '/v7/ratings/5',
    );
    expect(headers['Authorization'], 'Bearer secret-token');
  });

  test('/v7/auth/login에는 Bearer가 붙지 않는다', () async {
    final storage = _FakeTokenStorage()..token = 'secret-token';
    final headers = await _sendAndCaptureHeaders(
      storage,
      'POST',
      '/v7/auth/login',
    );
    expect(headers.containsKey('Authorization'), isFalse);
  });

  test('공개 GET /v7/members/{id}/ratings에는 Bearer가 붙지 않는다', () async {
    final storage = _FakeTokenStorage()..token = 'secret-token';
    final headers = await _sendAndCaptureHeaders(
      storage,
      'GET',
      '/v7/members/1/ratings',
    );
    expect(headers.containsKey('Authorization'), isFalse);
  });

  test('TMDB 호스트에는 Bearer가 붙지 않는다', () async {
    final storage = _FakeTokenStorage()..token = 'secret-token';
    final headers = await _sendAndCaptureHeaders(
      storage,
      'GET',
      '/v7/members/me',
      baseUrl: 'https://api.themoviedb.org/3',
    );
    expect(headers.containsKey('Authorization'), isFalse);
  });

  test('저장소 읽기 실패면 reject된다', () async {
    final dio = Dio(BaseOptions(baseUrl: movieLogBaseUrl));
    dio.interceptors.add(AuthInterceptor(_ThrowingTokenStorage()));

    await expectLater(
      dio.get('/v7/members/me'),
      throwsA(isA<DioException>()),
    );
  });
}
