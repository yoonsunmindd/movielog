import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bar.dart';
import '../widgets/genre_filter_bottom_sheet.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movielog_bottom_nav_bar.dart';

const List<String> _availableGenres = ['드라마', 'SF', '애니메이션', '스릴러'];
const String _selectedGenresPrefsKey = 'last_selected_genres';

class MovieListScreen extends StatefulWidget {
  /// 테스트에서 다른 모드의 서비스를 주입할 때 사용. 실제 앱에서는 비워두면
  /// 아래 기본 서비스(success 모드)가 쓰인다.
  final FakeMovieService? movieService;

  const MovieListScreen({super.key, this.movieService});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // 데모/디버그용: 모드를 바꾸려면 아래 한 줄만 고치면 된다.
  late final FakeMovieService _movieService =
      widget.movieService ??
      FakeMovieService(mode: FakeMovieServiceMode.success);
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  late Future<List<Movie>> _moviesFuture;
  Set<String> _selectedGenres = {};

  @override
  void initState() {
    super.initState();
    _moviesFuture = _loadInitialMovies();
  }

  /// 저장된 장르 복원까지 끝낸 뒤에 영화 목록을 가져온다.
  /// 둘 다 끝나야 FutureBuilder가 Success로 넘어가므로, 전체 목록이
  /// 먼저 보였다가 필터가 뒤늦게 적용되는 깜빡임이 없다.
  Future<List<Movie>> _loadInitialMovies() async {
    final saved = await _readSavedGenres();
    // FutureBuilder는 이 Future가 끝나야 다시 그려지지만, 필터 버튼은
    // FutureBuilder 밖에 있어서 setState 없이는 "전체"로 멈춰 있는다.
    if (saved != null && mounted) {
      setState(() {
        _selectedGenres = saved.where(_availableGenres.contains).toSet();
      });
    }
    return _movieService.fetchMovies();
  }

  /// 저장된 장르를 읽는다. 읽기에 실패해도 저장값이 없는 것과 동일하게
  /// null을 돌려줄 뿐, 화면에 에러를 노출하거나 영화 목록 로딩을 막지 않는다.
  Future<List<String>?> _readSavedGenres() async {
    try {
      return await _prefs.getStringList(_selectedGenresPrefsKey);
    } catch (_) {
      return null;
    }
  }

  void _retry() {
    setState(() {
      _moviesFuture = _movieService.fetchMovies();
    });
  }

  Future<void> _openGenreFilter() async {
    final result = await showGenreFilterBottomSheet(
      context,
      genres: _availableGenres,
      initialSelected: _selectedGenres,
    );
    if (!mounted || result == null) return;

    setState(() => _selectedGenres = result);
    await _prefs.setStringList(_selectedGenresPrefsKey, result.toList());
  }

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
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _openGenreFilter,
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(
                    _selectedGenres.isEmpty
                        ? '전체'
                        : _selectedGenres.join(', '),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MovieListLoading();
                  }
                  if (snapshot.hasError) {
                    return MovieListError(onRetry: _retry);
                  }

                  final movies = snapshot.data ?? [];
                  if (movies.isEmpty) {
                    return const MovieListEmpty(message: '아직 등록된 영화가 없어요');
                  }

                  final filteredMovies = _selectedGenres.isEmpty
                      ? movies
                      : movies
                            .where((movie) =>
                                _selectedGenres.contains(movie.genre))
                            .toList();
                  if (filteredMovies.isEmpty) {
                    return const MovieListEmpty(
                      message: '선택한 장르에 해당하는 영화가 없어요',
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredMovies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.52,
                        ),
                    itemBuilder: (context, index) =>
                        MovieCard(movie: filteredMovies[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MovieLogBottomNavBar(currentIndex: 1),
    );
  }
}
