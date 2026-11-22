import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/rating_api_service.dart';

Dio _fakeDio({
  required int statusCode,
  Map<String, dynamic>? data,
}) {
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

void main() {
  test('삭제는 200이고 바디가 없어도 성공 처리한다', () async {
    final publicDio = Dio();
    final authDio = _fakeDio(statusCode: 200, data: null);
    final service = RatingApiService(publicDio, authDio);

    await expectLater(service.deleteRating(2), completes);
  });

  test('등록 응답의 result를 RatingDto로 파싱한다', () async {
    final publicDio = Dio();
    final authDio = _fakeDio(
      statusCode: 200,
      data: {
        'isSuccess': true,
        'code': 'COMMON200',
        'message': 'ok',
        'result': {
          'ratingId': 10,
          'movieId': 20,
          'score': 5,
          'comment': '좋아요',
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      },
    );
    final service = RatingApiService(publicDio, authDio);

    final rating = await service.createRating(
      const CreateRatingRequest(movieId: 20, score: 5, comment: '좋아요'),
    );

    expect(rating.ratingId, 10);
    expect(rating.movieId, 20);
    expect(rating.score, 5);
  });

  test('등록 응답에 result가 없으면 StateError를 던진다', () async {
    final publicDio = Dio();
    final authDio = _fakeDio(
      statusCode: 200,
      data: {
        'isSuccess': true,
        'code': 'COMMON200',
        'message': 'ok',
        'result': null,
      },
    );
    final service = RatingApiService(publicDio, authDio);

    await expectLater(
      service.createRating(const CreateRatingRequest(movieId: 20, score: 5)),
      throwsA(isA<StateError>()),
    );
  });
}
