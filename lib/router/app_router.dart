import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/member_api_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/profile_screen.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/session_ratings_store.dart';
import '../view_models/sign_up_view_model.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

const _publicPaths = {'/login', '/signup'};

/// 상태만 보고 순수하게 리다이렉트를 결정한다(비동기 호출 없음). 테스트하기
/// 쉽게 GoRouter와 분리해서 둔다.
String? authRedirect(AuthStatus status, String location) {
  final isPublic = _publicPaths.contains(location);

  switch (status) {
    case AuthStatus.initializing:
    case AuthStatus.retryRequired:
      return location == '/start' ? null : '/start';
    case AuthStatus.signedOut:
    case AuthStatus.authenticating:
      return isPublic ? null : '/login';
    case AuthStatus.signedIn:
      return (location == '/start' || isPublic) ? '/home' : null;
  }
}

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/start',
      refreshListenable: authViewModel,
      redirect: (context, state) =>
          authRedirect(authViewModel.status, state.matchedLocation),
      routes: [
        GoRoute(path: '/start', builder: (context, state) => const SplashScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              LoginScreen(justSignedUp: state.extra == true),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
            create: (context) => SignUpViewModel(context.read<SignUpService>()),
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              ChangeNotifierProvider<MovieHomeViewModel>(
                create: (context) =>
                    MovieHomeViewModel(context.read<TmdbMovieService>())
                      ..loadPopular(),
                child: const HomeScreen(),
              ),
        ),
        GoRoute(
          path: '/movies',
          builder: (context, state) =>
              ChangeNotifierProvider<MovieListViewModel>(
                create: (context) =>
                    MovieListViewModel(context.read<TmdbMovieService>())
                      ..loadInitial(),
                child: const MovieListScreen(),
              ),
          routes: [
            GoRoute(
              path: ':movieId',
              builder: (context, state) {
                final movieId = int.tryParse(
                  state.pathParameters['movieId'] ?? '',
                );
                if (movieId == null) return const MovieDetailInvalidIdScreen();
                return MovieDetailLoader(
                  movieId: movieId,
                  initialMovie: state.extra as TmdbMovieDto?,
                );
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
              builder: (context, state) =>
                  ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      context.read<AuthViewModel>(),
                      context.read<SessionRatingsStore>(),
                    )..load(),
                    child: const MyRatingsScreen(),
                  ),
            ),
            GoRoute(
              path: 'profile/edit',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) => Consumer<AuthViewModel>(
                builder: (context, auth, _) {
                  final member = auth.member;
                  if (member == null) {
                    return EditProfileMemberGate(
                      isLoading: auth.memberStatus == MemberLoadStatus.loading,
                      onRetry: () => auth.loadMember(force: true),
                    );
                  }
                  return ChangeNotifierProvider<EditProfileViewModel>(
                    create: (context) => EditProfileViewModel(
                      context.read<MemberApiService>(),
                      auth,
                      member,
                    ),
                    child: const EditProfileScreen(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
