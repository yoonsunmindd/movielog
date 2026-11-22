import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';

Dio _fakeMovieDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'id': 1,
              'title': '테스트 영화',
              'overview': '',
              'genre_ids': [],
              'vote_average': 0,
              'popularity': 0,
            },
          ),
        );
      },
    ),
  );
  return dio;
}

const _sampleRating = {
  'ratingId': 1,
  'movieId': 1,
  'score': 4,
  'comment': null,
  'createdAt': '2026-01-01T00:00:00.000Z',
};

void main() {
  test('쓰기 성공 후 재조회 실패 시 refreshWarning이 설정되고 쓰기는 실패로 던지지 않는다', () async {
    var getCallCount = 0;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'GET') {
            getCallCount++;
            if (getCallCount == 1) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [_sampleRating],
                ),
              );
            } else {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                ),
              );
            }
          } else {
            handler.resolve(Response(requestOptions: options, statusCode: 200));
          }
        },
      ),
    );

    final viewModel = MyRatingsViewModel(
      1,
      RatingApiService(dio),
      TmdbMovieService(_fakeMovieDio()),
    );

    await viewModel.load();
    expect(viewModel.status, MyRatingsStatus.success);

    await viewModel.updateRating(1, 5, '좋아요');

    expect(viewModel.refreshWarning, isNotNull);
    expect(viewModel.status, MyRatingsStatus.success);
  });

  test('403/404 오류면 재조회하고 rethrow 한다', () async {
    var getCallCount = 0;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'GET') {
            getCallCount++;
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: []),
            );
          } else {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 403,
                  data: {
                    'isSuccess': false,
                    'code': 'COMMON403',
                    'message': '권한이 없어요',
                  },
                ),
              ),
            );
          }
        },
      ),
    );

    final viewModel = MyRatingsViewModel(
      1,
      RatingApiService(dio),
      TmdbMovieService(_fakeMovieDio()),
    );

    await viewModel.load();
    expect(getCallCount, 1);

    await expectLater(
      () => viewModel.updateRating(1, 5, null),
      throwsA(isA<DioException>()),
    );
    expect(getCallCount, 2);
  });

  test('400/409 오류면 재조회하지 않고 rethrow만 한다', () async {
    var getCallCount = 0;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'GET') {
            getCallCount++;
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: []),
            );
          } else {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 409,
                  data: {
                    'isSuccess': false,
                    'code': 'COMMON4091',
                    'message': '이미 등록된 평점이에요',
                  },
                ),
              ),
            );
          }
        },
      ),
    );

    final viewModel = MyRatingsViewModel(
      1,
      RatingApiService(dio),
      TmdbMovieService(_fakeMovieDio()),
    );

    await viewModel.load();
    expect(getCallCount, 1);

    await expectLater(
      () => viewModel.deleteRating(1),
      throwsA(isA<DioException>()),
    );
    expect(getCallCount, 1);
  });
}
