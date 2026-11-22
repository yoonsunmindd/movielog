import 'rating_dto.dart';
import 'tmdb_movie_dto.dart';

/// 평점 한 건과, 조회에 성공했다면 그 영화 정보를 함께 담는다.
/// movie가 null이면 TMDB 조회에 실패했거나 아직 하지 않은 상태다.
class RatingWithMovie {
  final RatingDto rating;
  final TmdbMovieDto? movie;

  const RatingWithMovie({required this.rating, this.movie});
}
