import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            colorFilter: const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('내가 등록한 평점', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, _) {
          switch (viewModel.status) {
            case MyRatingsStatus.idle:
            case MyRatingsStatus.loading:
              return const _RatingsLoading();
            case MyRatingsStatus.error:
              return _RatingsError(
                message: viewModel.message ?? '평점을 불러오지 못했어요.',
                onRetry: viewModel.load,
              );
            case MyRatingsStatus.empty:
              return const _RatingsEmpty();
            case MyRatingsStatus.success:
              return _RatingsList(
                ratings: viewModel.ratings,
                message: viewModel.message,
              );
          }
        },
      ),
    );
  }
}

class _RatingsLoading extends StatelessWidget {
  const _RatingsLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            '평점을 불러오는 중이에요',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _RatingsEmpty extends StatelessWidget {
  const _RatingsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '등록한 평점이 없어요',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}

class _RatingsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RatingsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            MovieLogButton(label: '다시 시도', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _RatingsList extends StatelessWidget {
  final List<RatingWithMovie> ratings;
  final String? message;

  const _RatingsList({required this.ratings, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              message!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ratings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _RatingCard(ratingWithMovie: ratings[index]),
          ),
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  final RatingWithMovie ratingWithMovie;

  const _RatingCard({required this.ratingWithMovie});

  @override
  Widget build(BuildContext context) {
    final rating = ratingWithMovie.rating;
    final movie = ratingWithMovie.movie;
    final textTheme = Theme.of(context).textTheme;

    final title = movie?.title ?? '영화 #${rating.movieId}';
    final subtitleText = rating.comment ?? (movie == null ? '포스터 정보 없음' : null);
    final createdAt = rating.createdAt.toLocal();
    final createdAtText =
        '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.'
        '${createdAt.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TmdbPosterImage(
              posterPath: movie?.posterPath,
              width: 64,
              height: 96,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '별점 ${rating.score} / 5',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitleText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  createdAtText,
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
