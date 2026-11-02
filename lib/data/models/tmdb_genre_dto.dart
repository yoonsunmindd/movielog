/// TMDB 장르(id/name) 하나를 매핑한 DTO.
class TmdbGenreDto {
  final int id;
  final String name;

  const TmdbGenreDto({required this.id, required this.name});

  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) {
    return TmdbGenreDto(id: json['id'] as int, name: json['name'] as String);
  }
}
