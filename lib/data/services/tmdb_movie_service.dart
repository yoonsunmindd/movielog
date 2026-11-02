import 'package:dio/dio.dart';
import '../models/tmdb_genre_dto.dart';
import '../models/tmdb_movie_page.dart';

/// TMDB API 호출 + DTO 변환만 담당한다.
/// "5개", "30개", "선택된 장르" 같은 화면 정책은 ViewModel에서 처리한다.
class TmdbMovieService {
  final Dio _dio;

  TmdbMovieService(this._dio);

  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'language': 'ko-KR', 'page': page},
    );
    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    List<int>? genreIds,
  }) async {
    final withGenres = (genreIds == null || genreIds.isEmpty)
        ? null
        : genreIds.join('|');
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'language': 'ko-KR',
        'sort_by': 'popularity.desc',
        'include_adult': false,
        'include_video': false,
        'page': page,
        'with_genres': ?withGenres,
      },
    );
    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TmdbGenreDto>> fetchGenres() async {
    final response = await _dio.get(
      '/genre/movie/list',
      queryParameters: {'language': 'ko'},
    );
    final genres =
        (response.data as Map<String, dynamic>)['genres'] as List<dynamic>;
    return genres
        .map((genre) => TmdbGenreDto.fromJson(genre as Map<String, dynamic>))
        .toList();
  }
}
