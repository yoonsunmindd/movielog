import 'package:flutter/foundation.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  final TmdbMovieService _service;

  MovieListViewModel(this._service);

  static const int _targetCount = 30;

  MovieListStatus status = MovieListStatus.idle;
  List<TmdbMovieDto> movies = [];
  List<TmdbGenreDto> genres = [];
  List<int>? selectedGenreIds;
  String? message;

  /// 기존 목록을 화면에 유지한 채로 뒤에서 다시 불러오는 중인지. Pull to
  /// Refresh와, 목록이 이미 있는 상태에서의 장르 전환/재시도가 모두 이 플래그를
  /// 함께 쓴다 — 둘 다 "화면은 그대로 두고 조용히 다시 받아온다"는 같은 동작.
  bool isRefreshing = false;

  List<int>? _lastSuccessfulGenreIds;
  bool _disposed = false;
  int _requestVersion = 0;

  bool get isLoading => status == MovieListStatus.loading;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadInitial() async {
    status = MovieListStatus.loading;
    notifyListeners();

    try {
      genres = await _service.fetchGenres();
    } catch (e) {
      // 장르 목록만 실패해도 "전체"로 영화 목록 로딩은 그대로 진행한다.
      genres = [];
    }

    await _loadMovies();
  }

  /// BottomSheet에서 "확인"을 눌렀을 때 호출한다. 선택이 없으면(빈 리스트)
  /// null로 정규화해서 with_genres 없이 "전체"로 취급한다.
  ///
  /// 반환값이 false면 "최근에 성공한 목록이 있는데 이번 요청은 실패"한
  /// 상황이라는 뜻이고, 호출한 쪽(View)이 재시도 Dialog를 띄워야 한다.
  /// true면 (성공했거나, 보여줄 목록이 아직 없어서 전체화면으로 알아서
  /// 처리했거나 둘 중 하나라) 더 할 일이 없다는 뜻이다.
  Future<bool> applySelectedGenres(List<int>? genreIds) async {
    if (isLoading || isRefreshing) return true; // 이미 처리 중이면 무시

    selectedGenreIds = (genreIds == null || genreIds.isEmpty)
        ? null
        : genreIds;

    if (movies.isEmpty) {
      status = MovieListStatus.loading;
      notifyListeners();
      await _loadMovies(); // 실패해도 전체화면 Error가 알아서 보여준다.
      return true;
    }

    return _loadKeepingListOnFailure();
  }

  Future<void> retry() async {
    status = MovieListStatus.loading;
    notifyListeners();

    await _loadMovies();
  }

  /// 현재 선택된 장르를 유지한 채로 page 1부터 다시 가져온다. 실패하면
  /// false를 돌려줘서 View가 재시도 Dialog를 띄우게 한다.
  Future<bool> refresh() async {
    if (isLoading || isRefreshing) return true;
    return _loadKeepingListOnFailure();
  }

  /// 재시도 Dialog의 "다시 시도" 버튼에서 호출한다. 이미 다른 요청이
  /// 진행 중이면(중복 탭) 조용히 무시한다.
  Future<bool> retryDiscoverKeepingList() async {
    if (isRefreshing) return true;
    return _loadKeepingListOnFailure();
  }

  /// 재시도 Dialog에서 "취소"를 눌렀을 때 호출한다. 필터 라벨/선택 상태를
  /// 마지막으로 성공했던 장르로 되돌려서, 화면에 보이는 목록과 라벨이
  /// 다시 일치하게 만든다.
  void cancelPendingGenreChange() {
    selectedGenreIds = _lastSuccessfulGenreIds;
    notifyListeners();
  }

  /// status는 success에 그대로 두고(목록이 화면에서 사라지지 않음) 뒤에서
  /// 다시 가져온다. 성공하면 movies를 교체하고, 실패하면 기존 movies는
  /// 손대지 않는다. 호출하는 쪽에서 이미 isLoading/isRefreshing 여부를
  /// 확인했다고 가정한다(이 메서드 자체가 isRefreshing을 세워서 중복 호출을
  /// 막는다).
  Future<bool> _loadKeepingListOnFailure() async {
    isRefreshing = true;
    notifyListeners();

    bool success;
    try {
      final result = await _fetchUpTo30();
      movies = result;
      status = result.isEmpty
          ? MovieListStatus.empty
          : MovieListStatus.success;
      _lastSuccessfulGenreIds = selectedGenreIds;
      success = true;
    } catch (e) {
      // 기존 movies/status는 그대로 둔다.
      success = false;
    }

    isRefreshing = false;
    if (!_disposed) notifyListeners();
    return success;
  }

  Future<void> _loadMovies() async {
    final version = ++_requestVersion;

    try {
      final result = await _fetchUpTo30();
      if (version != _requestVersion || _disposed) return; // 낡은 응답 무시

      movies = result;
      status = result.isEmpty
          ? MovieListStatus.empty
          : MovieListStatus.success;
      _lastSuccessfulGenreIds = selectedGenreIds;
    } catch (e) {
      if (version != _requestVersion || _disposed) return;
      // DioException뿐 아니라 파싱 오류 등도 전부 error로 전환한다.
      status = MovieListStatus.error;
      message = '영화 목록을 불러오지 못했어요';
    }

    if (!_disposed) notifyListeners();
  }

  /// page 1부터 Discover를 호출해서, 30개가 모이거나 더 이상 페이지가 없을
  /// 때까지 이어서 가져온다. TMDB id를 key로 쓰는 Map으로 중복을 제거한다.
  Future<List<TmdbMovieDto>> _fetchUpTo30() async {
    final collected = <int, TmdbMovieDto>{};
    var page = 1;
    var totalPages = 1;
    var lastResults = <TmdbMovieDto>[];

    do {
      final pageResult = await _service.discoverMovies(
        page: page,
        genreIds: selectedGenreIds,
      );
      totalPages = pageResult.totalPages;
      lastResults = pageResult.results;
      for (final movie in lastResults) {
        collected[movie.id] = movie;
      }
      page++;
    } while (collected.length < _targetCount &&
        page <= totalPages &&
        lastResults.isNotEmpty);

    return collected.values.take(_targetCount).toList();
  }
}
