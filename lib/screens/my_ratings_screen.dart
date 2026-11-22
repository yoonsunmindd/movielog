import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

const _sessionOnlyNotice = '이번 로그인 세션에서 등록한 평점만 표시돼요. 앱을 다시 시작하면 이전 평점은 '
    '이 화면에 나타나지 않아요.';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '등록한 평점이 없어요',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 12),
            Text(
              _sessionOnlyNotice,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
            ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            _sessionOnlyNotice,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  final RatingWithMovie ratingWithMovie;

  const _RatingCard({required this.ratingWithMovie});

  Future<void> _openEditDialog(BuildContext context) async {
    final viewModel = context.read<MyRatingsViewModel>();
    final rating = ratingWithMovie.rating;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment,
        onSubmit: (score, comment) =>
            viewModel.updateRating(rating.ratingId, score, comment),
      ),
    );
  }

  Future<void> _openDeleteDialog(BuildContext context) async {
    final viewModel = context.read<MyRatingsViewModel>();
    final rating = ratingWithMovie.rating;
    final messenger = ScaffoldMessenger.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () => viewModel.deleteRating(rating.ratingId),
      ),
    );

    if (shouldDelete == false) {
      messenger.showSnackBar(const SnackBar(content: Text('평점을 삭제하지 못했어요.')));
    }
  }

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
                Text(createdAtText, style: textTheme.labelSmall),
              ],
            ),
          ),
          Column(
            children: [
              _CardActionButton(
                label: '수정',
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                onPressed: () => _openEditDialog(context),
              ),
              const SizedBox(height: 8),
              _CardActionButton(
                label: '삭제',
                backgroundColor: AppColors.errorRed.withValues(alpha: 0.12),
                foregroundColor: AppColors.errorRed,
                onPressed: () => _openDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _CardActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size(56, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _DeleteRatingDialog extends StatefulWidget {
  final Future<void> Function() onConfirm;

  const _DeleteRatingDialog({required this.onConfirm});

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text('평점을 삭제할까요?', style: textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '삭제한 평점은 복구할 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      isSecondary: true,
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MovieLogButton(
                      label: '삭제',
                      isLoading: _isDeleting,
                      onPressed: _handleDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
