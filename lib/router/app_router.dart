import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/services/member_check_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../screens/start_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/profile_screen.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/sign_up_view_model.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/start',
  routes: [
    GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
    GoRoute(
      path: '/signup',
      builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
        create: (context) =>
            SignUpViewModel(context.read<MemberCheckService>()),
        child: const SignUpScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => ChangeNotifierProvider<MovieHomeViewModel>(
        create: (context) =>
            MovieHomeViewModel(context.read<TmdbMovieService>())
              ..loadPopular(),
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/movies',
      builder: (context, state) => ChangeNotifierProvider<MovieListViewModel>(
        create: (context) =>
            MovieListViewModel(context.read<TmdbMovieService>())
              ..loadInitial(),
        child: const MovieListScreen(),
      ),
      routes: [
        GoRoute(
          path: ':movieId',
          builder: (context, state) {
            final movieId = state.pathParameters['movieId']!;
            return MovieDetailScreen(movieId: movieId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/my',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'ratings',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => ChangeNotifierProvider<MyRatingsViewModel>(
            create: (context) => MyRatingsViewModel(
              context.read<RatingApiService>(),
              context.read<TmdbMovieService>(),
            )..load(),
            child: const MyRatingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
