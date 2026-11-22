import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'movie_log_client.dart';

final Uri _movieLogUri = Uri.parse(movieLogBaseUrl);

bool _isProtectedMovieLogPath(RequestOptions options) {
  if (options.uri.host != _movieLogUri.host) return false;
  final path = options.uri.path;
  return path == '/v7/members/me' ||
      path == '/v7/ratings' ||
      path.startsWith('/v7/ratings/');
}

/// MovieLog 보호 경로(호스트+path)에만 저장된 accessToken을 Bearer로 붙인다.
/// TMDB 등 다른 호스트나 공개 경로에는 붙지 않는다.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.remove('Authorization');

    if (!_isProtectedMovieLogPath(options)) {
      handler.next(options);
      return;
    }

    final String? token;
    try {
      token = await _tokenStorage.readAccessToken();
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: StateError('토큰 저장소를 읽지 못했습니다: $e'),
        ),
      );
      return;
    }

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
