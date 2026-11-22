import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../theme/app_colors.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/movie_detail_view_model.dart';
import 'movie_detail_screen.dart';

/// extra로 TmdbMovieDto를 안 받았거나 id가 일치하지 않으면 TMDB에서 직접
/// 조회한다. future는 initState에서 한 번만 만든다.
class MovieDetailLoader extends StatefulWidget {
  final int movieId;
  final TmdbMovieDto? initialMovie;

  const MovieDetailLoader({super.key, required this.movieId, this.initialMovie});

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late final Future<TmdbMovieDto>? _future;

  @override
  void initState() {
    super.initState();
    final initialMovie = widget.initialMovie;
    if (initialMovie != null && initialMovie.id == widget.movieId) {
      _future = null;
    } else {
      _future = context.read<TmdbMovieService>().fetchMovieDetail(widget.movieId);
    }
  }

  Widget _buildDetail(BuildContext context, TmdbMovieDto movie) {
    final memberId = context.read<LearningMemberSession>().memberId;
    return ChangeNotifierProvider<MovieDetailViewModel>(
      create: (context) => MovieDetailViewModel(
        context.read<RatingApiService>(),
        memberId,
        movie,
      ),
      child: const MovieDetailScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialMovie = widget.initialMovie;
    if (_future == null && initialMovie != null) {
      return _buildDetail(context, initialMovie);
    }

    return FutureBuilder<TmdbMovieDto>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('영화 정보를 불러오지 못했어요.')),
          );
        }
        return _buildDetail(context, snapshot.data!);
      },
    );
  }
}

/// movieId 경로 파라미터가 숫자가 아닐 때 보여주는 화면.
class MovieDetailInvalidIdScreen extends StatelessWidget {
  const MovieDetailInvalidIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('잘못된 영화 id예요.')),
    );
  }
}
