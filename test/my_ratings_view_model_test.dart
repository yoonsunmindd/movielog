import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/session_ratings_store.dart';

class _FakeTokenStorage implements TokenStorage {
  String? token = 'fake-token';

  @override
  Future<void> saveAccessToken(String token) async => this.token = token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async => token = null;
}

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

AuthViewModel _signedInAuthViewModel(SessionRatingsStore store) {
  final authViewModel = AuthViewModel(
    AuthApiService(Dio()),
    MemberApiService(Dio()),
    _FakeTokenStorage(),
    store,
  );
  authViewModel.status = AuthStatus.signedIn;
  return authViewModel;
}

RatingDto _rating(int ratingId) => RatingDto(
  ratingId: ratingId,
  movieId: 1,
  score: 4,
  comment: null,
  createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
);

Dio _rejectingAuthDio(String code, int statusCode) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: statusCode,
              data: {'isSuccess': false, 'code': code, 'message': '실패'},
            ),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test('403이면 로그아웃하지 않는다', () async {
    final store = SessionRatingsStore()..add(_rating(1));
    final authViewModel = _signedInAuthViewModel(store);
    final ratingApiService = RatingApiService(
      Dio(),
      _rejectingAuthDio('RATING403_1', 403),
    );
    final viewModel = MyRatingsViewModel(
      ratingApiService,
      TmdbMovieService(_fakeMovieDio()),
      authViewModel,
      store,
    );

    await expectLater(
      () => viewModel.updateRating(1, 5, null),
      throwsA(isA<DioException>()),
    );

    expect(authViewModel.status, AuthStatus.signedIn);
    expect(store.ratings, hasLength(1));
  });

  test('404면 세션 평점에서 해당 항목을 제거한다', () async {
    final store = SessionRatingsStore()..add(_rating(1));
    final authViewModel = _signedInAuthViewModel(store);
    final ratingApiService = RatingApiService(
      Dio(),
      _rejectingAuthDio('RATING404_1', 404),
    );
    final viewModel = MyRatingsViewModel(
      ratingApiService,
      TmdbMovieService(_fakeMovieDio()),
      authViewModel,
      store,
    );

    await expectLater(
      () => viewModel.updateRating(1, 5, null),
      throwsA(isA<DioException>()),
    );

    expect(store.ratings, isEmpty);
  });

  test('로그아웃하면 이전 세션의 평점이 비워진다', () async {
    final store = SessionRatingsStore()..add(_rating(1));
    final authViewModel = _signedInAuthViewModel(store);

    expect(store.ratings, hasLength(1));
    await authViewModel.logout();
    expect(store.ratings, isEmpty);
  });
}
