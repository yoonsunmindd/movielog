import 'package:flutter/foundation.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieHomeStatus { idle, loading, success, empty, error }

class MovieHomeViewModel extends ChangeNotifier {
  final TmdbMovieService _service;

  MovieHomeViewModel(this._service);

  MovieHomeStatus status = MovieHomeStatus.idle;
  List<TmdbMovieDto> popularMovies = [];
  String? message;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadPopular() async {
    if (status == MovieHomeStatus.loading) return;

    status = MovieHomeStatus.loading;
    notifyListeners();

    try {
      final page = await _service.fetchPopular();
      final top5 = page.results.take(5).toList();
      popularMovies = top5;
      status = top5.isEmpty ? MovieHomeStatus.empty : MovieHomeStatus.success;
    } catch (e) {
      // DioException뿐 아니라 파싱 오류 등도 전부 error로 전환한다.
      status = MovieHomeStatus.error;
      message = '인기 영화를 불러오지 못했어요';
    }

    if (!_disposed) notifyListeners();
  }
}
