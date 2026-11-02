import 'tmdb_movie_dto.dart';

/// TMDB의 페이지네이션 응답(인기 영화, Discover 공통 형태)을 매핑한 DTO.
class TmdbMoviePageDto {
  final int page;
  final List<TmdbMovieDto> results;
  final int totalPages;
  final int totalResults;

  const TmdbMoviePageDto({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TmdbMoviePageDto.fromJson(Map<String, dynamic> json) {
    return TmdbMoviePageDto(
      page: json['page'] as int,
      results: (json['results'] as List<dynamic>)
          .map((movie) => TmdbMovieDto.fromJson(movie as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }
}
