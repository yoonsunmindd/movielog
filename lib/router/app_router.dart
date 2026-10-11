import 'package:go_router/go_router.dart';
import '../screens/start_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/start',
  routes: [
    GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/movies',
      builder: (context, state) => const MovieListScreen(),
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
    GoRoute(path: '/my', builder: (context, state) => const ProfileScreen()),
  ],
);
