import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  static const int sampleMemberId = 1;

  final RatingApiService _ratingApiService;
  final TmdbMovieService _tmdbMovieService;

  MyRatingsViewModel(this._ratingApiService, this._tmdbMovieService);

  MyRatingsStatus status = MyRatingsStatus.idle;
  List<RatingWithMovie> ratings = [];
  String? message;

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
    notifyListeners();

    List<RatingDto> fetchedRatings;
    try {
      fetchedRatings = await _ratingApiService.fetchMyRatings(sampleMemberId);
    } on DioException catch (e) {
      if (version != _requestVersion || _disposed) return;
      status = MyRatingsStatus.error;
      message = writeMyRatingsErrorMessage(e);
      notifyListeners();
      return;
    } catch (e) {
      if (version != _requestVersion || _disposed) return;
      status = MyRatingsStatus.error;
      message = '평점을 불러오지 못했어요.';
      notifyListeners();
      return;
    }

    if (version != _requestVersion || _disposed) return;

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

      if (version != _requestVersion || _disposed) return;
      result.add(RatingWithMovie(rating: rating, movie: movie));
    }

    ratings = result;
    status = ratings.isEmpty ? MyRatingsStatus.empty : MyRatingsStatus.success;
    message = anyMovieFailed ? '일부 영화 정보를 불러오지 못했어요.' : null;

    if (!_disposed) notifyListeners();
  }
}
