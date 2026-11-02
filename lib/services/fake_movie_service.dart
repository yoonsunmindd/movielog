import '../models/movie.dart';

enum FakeMovieServiceMode { success, empty, error, errorOnce }

/// Mock 영화 목록을 비동기로 돌려주는 가짜 서비스.
/// mode는 생성자 인자로만 바꾸면 되고, 화면 코드는 건드릴 필요 없다.
//
// TODO(5주차 유저별 평점 조회 API): FakeMovieService를 실제 API Service로 교체
class FakeMovieService {
  final FakeMovieServiceMode mode;
  final Duration delay;

  bool _hasFailedOnce = false;

  FakeMovieService({
    this.mode = FakeMovieServiceMode.success,
    this.delay = const Duration(seconds: 1),
  });

  Future<List<Movie>> fetchMovies() async {
    await Future.delayed(delay);

    switch (mode) {
      case FakeMovieServiceMode.success:
        return mockMovies;
      case FakeMovieServiceMode.empty:
        return [];
      case FakeMovieServiceMode.error:
        throw Exception('영화 목록을 불러오지 못했습니다.');
      case FakeMovieServiceMode.errorOnce:
        if (!_hasFailedOnce) {
          _hasFailedOnce = true;
          throw Exception('영화 목록을 불러오지 못했습니다.');
        }
        return mockMovies;
    }
  }
}
