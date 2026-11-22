import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_error.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';
import 'session_ratings_store.dart';

enum MyRatingsStatus { idle, loading, success, empty }

/// v7에는 토큰 기반 "내 평점 전체 조회"가 없어서, 이 화면은 서버에서 다시
/// 불러오지 않고 SessionRatingsStore(이번 로그인 세션에서 등록/수정/삭제한
/// 평점)를 보여준다. 여기서 하는 비동기 작업은 TMDB 포스터/제목 조회뿐이다.
class MyRatingsViewModel extends ChangeNotifier {
  final RatingApiService _ratingApiService;
  final TmdbMovieService _tmdbMovieService;
  final AuthViewModel _authViewModel;
  final SessionRatingsStore _sessionRatingsStore;

  MyRatingsViewModel(
    this._ratingApiService,
    this._tmdbMovieService,
    this._authViewModel,
    this._sessionRatingsStore,
  ) {
    _sessionRatingsStore.addListener(_handleStoreChanged);
  }

  MyRatingsStatus status = MyRatingsStatus.idle;
  List<RatingWithMovie> ratings = [];
  String? message;

  final Map<int, TmdbMovieDto?> _movieCache = {};
  bool _disposed = false;
  int _requestVersion = 0;

  @override
  void dispose() {
    _disposed = true;
    _sessionRatingsStore.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _handleStoreChanged() => load();

  Future<void> load() async {
    final version = ++_requestVersion;
    final sessionVersion = _authViewModel.sessionVersion;
    status = MyRatingsStatus.loading;
    message = null;
    notifyListeners();

    var anyMovieFailed = false;
    final result = <RatingWithMovie>[];
    for (final rating in _sessionRatingsStore.ratings) {
      TmdbMovieDto? movie;
      if (_movieCache.containsKey(rating.movieId)) {
        movie = _movieCache[rating.movieId];
      } else {
        try {
          movie = await _tmdbMovieService.findMovieById(rating.movieId);
          _movieCache[rating.movieId] = movie;
        } catch (e) {
          anyMovieFailed = true;
          movie = null;
        }
      }

      if (version != _requestVersion ||
          _disposed ||
          sessionVersion != _authViewModel.sessionVersion) {
        return;
      }
      result.add(RatingWithMovie(rating: rating, movie: movie));
    }

    if (version != _requestVersion || _disposed) return;
    ratings = result;
    status = ratings.isEmpty ? MyRatingsStatus.empty : MyRatingsStatus.success;
    message = anyMovieFailed ? '일부 영화 정보를 불러오지 못했어요.' : null;
    notifyListeners();
  }

  Future<void> updateRating(int ratingId, int score, String? comment) async {
    final version = _authViewModel.sessionVersion;
    try {
      final updated = await _ratingApiService.updateRating(
        ratingId,
        score,
        comment,
      );
      if (version == _authViewModel.sessionVersion) {
        _sessionRatingsStore.replace(updated);
      }
    } on DioException catch (e) {
      if (version == _authViewModel.sessionVersion) {
        await _handleWriteError(e, ratingId: ratingId);
      }
      rethrow;
    }
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _authViewModel.sessionVersion;
    try {
      await _ratingApiService.deleteRating(ratingId);
      if (version == _authViewModel.sessionVersion) {
        _sessionRatingsStore.remove(ratingId);
      }
    } on DioException catch (e) {
      if (version == _authViewModel.sessionVersion) {
        await _handleWriteError(e, ratingId: ratingId);
      }
      rethrow;
    }
  }

  Future<void> _handleWriteError(DioException e, {required int ratingId}) async {
    final code = apiErrorCode(e);
    if (isAuthExpiredCode(code)) {
      // 로그인 화면 이동과 만료 안내는 Router와 로그인 화면이 담당한다.
      await _authViewModel.expireSession();
    } else if (code == 'RATING404_1') {
      _sessionRatingsStore.remove(ratingId);
    }
    // RATING403_1/RATING409_1/COMMON400/그 외 통신 오류는 로그아웃하지 않고,
    // 서버 message를 Dialog가 그대로 보여주도록 rethrow만 한다.
  }
}
