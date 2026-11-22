import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  final int memberId;
  final RatingApiService _ratingApiService;
  final TmdbMovieService _tmdbMovieService;

  MyRatingsViewModel(
    this.memberId,
    this._ratingApiService,
    this._tmdbMovieService,
  );

  MyRatingsStatus status = MyRatingsStatus.idle;
  List<RatingWithMovie> ratings = [];
  String? message;

  /// 쓰기(등록/수정/삭제)는 성공했지만 그 직후 재조회가 실패했을 때만 쓴다.
  /// 목록은 쓰기 성공 이전 상태로 유지하고, 이 문구로 "다시 조회"를 안내한다.
  String? refreshWarning;

  final Map<int, TmdbMovieDto?> _movieCache = {};
  bool _disposed = false;
  int _requestVersion = 0;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsStatus.loading;
    message = null;
    refreshWarning = null;
    notifyListeners();

    try {
      final built = await _fetchRatingsWithMovies();
      if (version != _requestVersion || _disposed) return;
      ratings = built.ratings;
      status = ratings.isEmpty ? MyRatingsStatus.empty : MyRatingsStatus.success;
      message = built.anyMovieFailed ? '일부 영화 정보를 불러오지 못했어요.' : null;
    } on DioException catch (e) {
      if (version != _requestVersion || _disposed) return;
      status = MyRatingsStatus.error;
      message = writeErrorMessage(e);
    } catch (e) {
      if (version != _requestVersion || _disposed) return;
      status = MyRatingsStatus.error;
      message = '평점을 불러오지 못했어요.';
    }

    if (!_disposed) notifyListeners();
  }

  Future<void> updateRating(int ratingId, int score, String? comment) async {
    await _writeAndRefresh(
      () => _ratingApiService.updateRating(memberId, ratingId, score, comment),
    );
  }

  Future<void> deleteRating(int ratingId) async {
    await _writeAndRefresh(
      () => _ratingApiService.deleteRating(memberId, ratingId),
    );
  }

  /// 쓰기 요청을 보내고, 실패하면 message를 세팅한 뒤 (필요하면 재조회하고)
  /// 그대로 다시 던져서 호출한 Dialog가 실패로 처리하게 한다. 성공하면
  /// 재조회하되, 그 재조회 자체가 실패해도 쓰기는 실패로 취급하지 않는다.
  Future<void> _writeAndRefresh(Future<void> Function() write) async {
    try {
      await write();
    } on DioException catch (e) {
      message = writeErrorMessage(e);
      if (shouldRefreshAfterRatingError(e)) {
        await load();
      } else if (!_disposed) {
        notifyListeners();
      }
      rethrow;
    }

    await _refreshAfterWrite();
  }

  Future<void> _refreshAfterWrite() async {
    try {
      final built = await _fetchRatingsWithMovies();
      ratings = built.ratings;
      status = ratings.isEmpty ? MyRatingsStatus.empty : MyRatingsStatus.success;
      message = built.anyMovieFailed ? '일부 영화 정보를 불러오지 못했어요.' : null;
      refreshWarning = null;
    } catch (e) {
      refreshWarning = '최신 목록을 다시 불러오지 못했어요.';
    }

    if (!_disposed) notifyListeners();
  }

  Future<_RatingsFetchResult> _fetchRatingsWithMovies() async {
    final fetchedRatings = await _ratingApiService.fetchMyRatings(memberId);

    var anyMovieFailed = false;
    final result = <RatingWithMovie>[];
    for (final rating in fetchedRatings) {
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
      result.add(RatingWithMovie(rating: rating, movie: movie));
    }

    return _RatingsFetchResult(ratings: result, anyMovieFailed: anyMovieFailed);
  }
}

class _RatingsFetchResult {
  final List<RatingWithMovie> ratings;
  final bool anyMovieFailed;

  const _RatingsFetchResult({required this.ratings, required this.anyMovieFailed});
}
