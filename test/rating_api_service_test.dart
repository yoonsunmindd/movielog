import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/services/rating_api_service.dart';

void main() {
  test('삭제 204를 JSON 파싱 없이 성공 처리한다', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(requestOptions: options, statusCode: 204));
        },
      ),
    );
    final service = RatingApiService(dio);

    await expectLater(service.deleteRating(1, 2), completes);
  });

  test('등록 201을 JSON 파싱 없이 성공 처리한다', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(requestOptions: options, statusCode: 201, data: null),
          );
        },
      ),
    );
    final service = RatingApiService(dio);

    await expectLater(
      service.createRating(
        1,
        const CreateRatingRequest(movieId: 10, score: 5),
      ),
      completes,
    );
  });
}
