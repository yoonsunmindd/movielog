import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bar.dart';
import '../widgets/featured_movie_card.dart';
import '../widgets/movie_card.dart';
import '../widgets/movielog_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featuredMovie = mockMovies.firstWhere((movie) => movie.isFeatured);
    final otherMovies = mockMovies
        .where((movie) => !movie.isFeatured)
        .toList();

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
      body: SingleChildScrollView(
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
            FeaturedMovieCard(movie: featuredMovie),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('인기 영화', style: Theme.of(context).textTheme.titleMedium),
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
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 140,
                  child: MovieCard(movie: otherMovies[index]),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MovieLogBottomNavBar(currentIndex: 0),
    );
  }
}
