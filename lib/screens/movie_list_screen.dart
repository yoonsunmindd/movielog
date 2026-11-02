import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/genre_filter_bottom_sheet.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movie_list_retry_dialog.dart';
import '../widgets/movielog_bottom_nav_bar.dart';
import '../widgets/tmdb_movie_card.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MovieLogAppBar(
        title: '영화',
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<MovieListViewModel>(
              builder: (context, viewModel, _) {
                final enabled =
                    !viewModel.isLoading && !viewModel.isRefreshing;
                return Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: enabled
                          ? () => _openGenreFilter(context, viewModel)
                          : null,
                      icon: const Icon(Icons.tune, size: 18),
                      label: Text(_genreFilterLabel(viewModel)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<MovieListViewModel>(
                builder: (context, viewModel, _) {
                  switch (viewModel.status) {
                    case MovieListStatus.idle:
                    case MovieListStatus.loading:
                      return const MovieListLoading();
                    case MovieListStatus.error:
                      return MovieListError(onRetry: viewModel.retry);
                    case MovieListStatus.empty:
                      return const MovieListEmpty(
                        message: '선택한 장르에 해당하는 영화가 없어요',
                      );
                    case MovieListStatus.success:
                      return RefreshIndicator(
                        onRefresh: () => _handleRefresh(context, viewModel),
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: viewModel.movies.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.52,
                              ),
                          itemBuilder: (context, index) =>
                              TmdbMovieCard(movie: viewModel.movies[index]),
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MovieLogBottomNavBar(currentIndex: 1),
    );
  }

  String _genreFilterLabel(MovieListViewModel viewModel) {
    final ids = viewModel.selectedGenreIds;
    if (ids == null || ids.isEmpty) return '전체';
    final names = viewModel.genres
        .where((genre) => ids.contains(genre.id))
        .map((genre) => genre.name);
    return names.isEmpty ? '전체' : names.join(', ');
  }

  Future<void> _openGenreFilter(
    BuildContext context,
    MovieListViewModel viewModel,
  ) async {
    final result = await showGenreFilterBottomSheet(
      context,
      genres: viewModel.genres,
      initialSelected: {...?viewModel.selectedGenreIds},
    );
    if (result == null) return;

    final succeeded = await viewModel.applySelectedGenres(result.toList());
    if (!succeeded && context.mounted) {
      await _showRetryDialogLoop(context, viewModel);
    }
  }

  Future<void> _handleRefresh(
    BuildContext context,
    MovieListViewModel viewModel,
  ) async {
    final succeeded = await viewModel.refresh();
    if (!succeeded && context.mounted) {
      await _showRetryDialogLoop(context, viewModel);
    }
  }

  /// 실패할 때마다 Dialog를 다시 띄우고, 성공하거나 취소하면 멈춘다.
  Future<void> _showRetryDialogLoop(
    BuildContext context,
    MovieListViewModel viewModel,
  ) async {
    while (true) {
      final shouldRetry = await showDialog<bool>(
        context: context,
        builder: (_) => const MovieListRetryDialog(),
      );

      if (shouldRetry != true) {
        viewModel.cancelPendingGenreChange();
        return;
      }

      final succeeded = await viewModel.retryDiscoverKeepingList();
      if (succeeded) return;
      if (!context.mounted) return;
    }
  }
}
