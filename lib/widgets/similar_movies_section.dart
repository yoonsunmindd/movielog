import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';

/// 상세 화면 하단의 "비슷한 영화" 추천 목록.
///
/// 다른 영화를 탭하면 push가 아니라 pushReplacement를 사용한다.
/// push를 쓰면 상세 화면을 넘나들 때마다 스택이 계속 쌓여서 뒤로가기를
/// 여러 번 눌러야 목록으로 돌아가지만, pushReplacement는 현재 상세 화면만
/// 새 영화의 상세 화면으로 교체하므로 뒤로가기 한 번이면 항상 영화 목록으로
/// 돌아간다 (그 아래 쌓인 목록 화면 스택은 그대로 유지됨).
class SimilarMoviesSection extends StatelessWidget {
  final Movie currentMovie;

  const SimilarMoviesSection({super.key, required this.currentMovie});

  @override
  Widget build(BuildContext context) {
    final similarMovies = mockMovies
        .where(
          (movie) =>
              movie.genre == currentMovie.genre &&
              movie.id != currentMovie.id,
        )
        .toList();

    if (similarMovies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('비슷한 영화', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: similarMovies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = similarMovies[index];
              return GestureDetector(
                onTap: () =>
                    context.pushReplacement('/movies/${movie.id}'),
                child: SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 2 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            movie.posterAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
