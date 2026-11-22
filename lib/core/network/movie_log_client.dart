import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// 워크북 자체 서버(회원가입, 중복 확인, 로그인) 전용 baseUrl.
/// TMDB 클라이언트와는 분리해서 쓴다.
const String movieLogBaseUrl = 'https://workbook.devnoco.com';

/// 공개 엔드포인트 전용 Client. Interceptor를 붙이지 않는다.
Dio createMovieLogClient() {
  return Dio(
    BaseOptions(
      baseUrl: movieLogBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}

/// 로그인이 필요한 보호 엔드포인트 전용 Client. AuthInterceptor가 저장된
/// accessToken을 Authorization 헤더로 붙여준다.
Dio createAuthMovieLogClient(TokenStorage tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: movieLogBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AuthInterceptor(tokenStorage));
  return dio;
}
