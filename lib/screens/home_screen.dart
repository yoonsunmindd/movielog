import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../view_models/movie_home_view_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movielog_bottom_nav_bar.dart';
import '../widgets/tmdb_featured_movie_card.dart';
import '../widgets/tmdb_movie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MovieLogAppBar(
        title: 'MovieLog',
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘은 어떤\n영화를 볼까요?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<MovieHomeViewModel>(
                builder: (context, viewModel, _) {
                  switch (viewModel.status) {
                    case MovieHomeStatus.idle:
                    case MovieHomeStatus.loading:
                      return const MovieListLoading();
                    case MovieHomeStatus.error:
                      return MovieListError(onRetry: viewModel.loadPopular);
                    case MovieHomeStatus.empty:
                      return const MovieListEmpty(message: '인기 영화를 찾을 수 없어요');
                    case MovieHomeStatus.success:
                      final featuredMovie = viewModel.popularMovies.first;
                      final otherMovies = viewModel.popularMovies
                          .skip(1)
                          .toList();
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TmdbFeaturedMovieCard(movie: featuredMovie),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '인기 영화',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                TextButton(
                                  onPressed: () => context.go('/movies'),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('전체보기'),
                                      Icon(Icons.chevron_right, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 260,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: otherMovies.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) => SizedBox(
                                  width: 140,
                                  child: TmdbMovieCard(
                                    movie: otherMovies[index],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MovieLogBottomNavBar(currentIndex: 0),
    );
  }
}
