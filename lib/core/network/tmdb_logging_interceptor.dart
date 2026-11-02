import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// TMDB 요청/응답/오류를 콘솔에 로그로 남긴다. kDebugMode일 때만 등록해서 쓴다.
/// 화면에 표시하거나 저장하지 않고, Authorization 값은 그대로 찍히지 않게 마스킹한다.
class TmdbLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '[TMDB] → ${options.method} ${options.uri} '
      'query=${options.queryParameters} '
      'headers=${_maskHeaders(options.headers)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[TMDB] ← ${response.statusCode} ${response.requestOptions.uri} '
      'body=${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[TMDB] ✕ ${err.requestOptions.uri} message=${err.message}');
    handler.next(err);
  }

  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = Map<String, dynamic>.from(headers);
    if (masked.containsKey('Authorization')) {
      masked['Authorization'] = 'Bearer ***';
    }
    return masked;
  }
}
