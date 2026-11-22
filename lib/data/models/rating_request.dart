/// 서버는 1~5 사이의 정수 score만 받는다. UI는 반 점을 허용하지 않지만,
/// 쓰기 요청으로 나가기 직전에 한 번 더 검증한다.
int validateServerScore(double score) {
  if (score != score.roundToDouble() || score < 1 || score > 5) {
    throw ArgumentError('평점은 1~5 사이의 정수여야 합니다: $score');
  }
  return score.round();
}

/// 평점 등록 요청 바디. comment가 null이거나 빈 문자열이면 키 자체를 생략한다.
class CreateRatingRequest {
  final int movieId;
  final int score;
  final String? comment;

  const CreateRatingRequest({
    required this.movieId,
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    'movieId': movieId,
    'score': score,
    if (comment != null && comment!.isNotEmpty) 'comment': comment,
  };
}
