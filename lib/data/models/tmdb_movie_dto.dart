/// TMDB 영화 한 편의 응답을 매핑한 DTO.
class TmdbMovieDto {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final double voteAverage;
  final double popularity;

  const TmdbMovieDto({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.genreIds,
    required this.voteAverage,
    required this.popularity,
  });

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDto(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '제목 없음',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((id) => id as int)
              .toList() ??
          const [],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
