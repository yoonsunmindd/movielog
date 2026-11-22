/// 워크북 서버의 평점 한 건. createdAt은 UTC로 들어온다.
class RatingDto {
  final int ratingId;
  final int movieId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  const RatingDto({
    required this.ratingId,
    required this.movieId,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  factory RatingDto.fromJson(Map<String, dynamic> json) {
    return RatingDto(
      ratingId: json['ratingId'] as int,
      movieId: json['movieId'] as int,
      score: json['score'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
