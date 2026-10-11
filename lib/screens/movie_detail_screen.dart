import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_rating_input_dialog.dart';
import '../widgets/similar_movies_section.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _userRating;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기에서 삭제했어요'),
      ),
    );
  }

  Future<void> _openRatingDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => MovieRatingInputDialog(initialRating: _userRating ?? 0),
    );
    if (result != null && mounted) {
      setState(() => _userRating = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('평점을 등록했어요 (${result.toStringAsFixed(1)}점)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(widget.movieId);
    final textTheme = Theme.of(context).textTheme;

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cinema Archive')),
        body: const Center(child: Text('영화를 찾을 수 없어요.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/share.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공유 기능은 준비 중이에요')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.year} · ${movie.genre} · ${movie.runtimeMinutes}분',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.rating,
                        itemCount: 5,
                        itemSize: 20,
                        unratedColor: AppColors.border,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ' (${movie.reviewCount})',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  if (_userRating != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '내가 남긴 평점: ${_userRating!.toStringAsFixed(1)}점',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in movie.tags)
                        Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primaryLight,
                          side: BorderSide.none,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('시놉시스', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    movie.synopsis,
                    style: textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  SimilarMoviesSection(currentMovie: movie),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: SvgPicture.asset(
                    'assets/icons/bookmark.svg',
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      _isFavorite ? AppColors.primary : AppColors.textTertiary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: Text(_isFavorite ? '즐겨찾기 완료' : '즐겨찾기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isFavorite
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    side: BorderSide(
                      color: _isFavorite
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openRatingDialog,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('평점 남기기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
