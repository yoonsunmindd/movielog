import 'package:dio/dio.dart';

/// 워크북 자체 서버(회원 중복 확인, 평점 조회) 전용 Dio Client.
/// TMDB 클라이언트와는 분리해서 쓴다.
Dio createMovieLogClient() {
  return Dio(
    BaseOptions(
      baseUrl: 'https://workbook.devnoco.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
