import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_error.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'session_ratings_store.dart';
import 'submit_status.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final RatingApiService _ratingApiService;
  final AuthViewModel _authViewModel;
  final SessionRatingsStore _sessionRatingsStore;
  final TmdbMovieDto movie;

  MovieDetailViewModel(
    this._ratingApiService,
    this._authViewModel,
    this._sessionRatingsStore,
    this.movie,
  );

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get canRate => _authViewModel.status == AuthStatus.signedIn;

  /// 실패하면 그대로 다시 던져서, 호출한 RatingDialog가 자기 화면에
  /// 오류 문구를 보여줄 수 있게 한다.
  Future<void> createRating(int score, String? comment) async {
    if (!canRate) {
      throw StateError('로그인이 필요합니다.');
    }
    if (submitStatus == SubmitStatus.submitting) return;

    final version = _authViewModel.sessionVersion;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      final rating = await _ratingApiService.createRating(
        CreateRatingRequest(movieId: movie.id, score: score, comment: comment),
      );

      // 로그아웃/세션 전환 뒤에 늦게 도착한 응답은 세션 평점에 반영하지 않는다.
      if (version != _authViewModel.sessionVersion || _disposed) return;
      _sessionRatingsStore.add(rating);
      submitStatus = SubmitStatus.success;
      notifyListeners();
    } on DioException catch (e) {
      if (isAuthExpiredCode(apiErrorCode(e))) {
        await _authViewModel.expireSession();
        return;
      }
      if (version != _authViewModel.sessionVersion || _disposed) rethrow;
      submitStatus = SubmitStatus.error;
      submitMessage = apiErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }
}
