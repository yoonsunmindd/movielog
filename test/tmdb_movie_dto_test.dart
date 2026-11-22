import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';

void main() {
  test('fromJson이 TMDB 응답 필드를 그대로 매핑한다', () {
    final dto = TmdbMovieDto.fromJson({
      'id': 42,
      'title': '별빛 아래 우리',
      'overview': '설명입니다',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'release_date': '2024-01-01',
      'genre_ids': [18, 10749],
      'vote_average': 8.5,
      'popularity': 123.4,
    });

    expect(dto.id, 42);
    expect(dto.title, '별빛 아래 우리');
    expect(dto.overview, '설명입니다');
    expect(dto.posterPath, '/poster.jpg');
    expect(dto.genreIds, [18, 10749]);
    expect(dto.voteAverage, 8.5);
    expect(dto.popularity, 123.4);
  });

  test('title/overview/poster_path가 null이면 기본값으로 처리한다', () {
    final dto = TmdbMovieDto.fromJson({
      'id': 1,
      'title': null,
      'overview': null,
      'poster_path': null,
      'genre_ids': null,
      'vote_average': null,
      'popularity': null,
    });

    expect(dto.title, '제목 없음');
    expect(dto.overview, '');
    expect(dto.posterPath, isNull);
    expect(dto.genreIds, isEmpty);
    expect(dto.voteAverage, 0.0);
    expect(dto.popularity, 0.0);
  });
}
