import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'submit_status.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final RatingApiService _ratingApiService;
  final int? memberId;
  final TmdbMovieDto movie;

  MovieDetailViewModel(this._ratingApiService, this.memberId, this.movie);

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get canRate => memberId != null;

  /// 실패하면 그대로 다시 던져서, 호출한 RatingDialog가 자기 화면에
  /// 오류 문구를 보여줄 수 있게 한다.
  Future<void> createRating(int score, String? comment) async {
    final id = memberId;
    if (id == null) {
      throw StateError('먼저 회원가입을 완료해 주세요.');
    }
    if (submitStatus == SubmitStatus.submitting) return;

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      await _ratingApiService.createRating(
        id,
        CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );
      submitStatus = SubmitStatus.success;
    } on DioException catch (e) {
      submitStatus = SubmitStatus.error;
      submitMessage = writeErrorMessage(e);
      if (!_disposed) notifyListeners();
      rethrow;
    }

    if (!_disposed) notifyListeners();
  }
}
