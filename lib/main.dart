import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'core/storage/token_storage.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_api_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/session_ratings_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MovieLogApp());
}

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final movieLogDio = createMovieLogClient();
    final tokenStorage = SecureTokenStorage();
    final authMovieLogDio = createAuthMovieLogClient(tokenStorage);

    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<SignUpService>(
          create: (_) => SignUpService(movieLogDio),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogDio, authMovieLogDio),
        ),
        Provider<TokenStorage>(create: (_) => tokenStorage),
        Provider<AuthApiService>(
          create: (_) => AuthApiService(movieLogDio),
        ),
        Provider<MemberApiService>(
          create: (_) => MemberApiService(authMovieLogDio),
        ),
        ChangeNotifierProvider<SessionRatingsStore>(
          create: (_) => SessionRatingsStore(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
            context.read<SessionRatingsStore>(),
          ),
        ),
      ],
      child: const _MovieLogRouterApp(),
    );
  }
}

/// GoRouter를 initState에서 한 번만 만들고, 첫 프레임 이후 세션 복구를
/// 시작한다. signedIn으로 바뀔 때마다 내 정보를 한 번 불러온다(ShellRoute가
/// 없어서, 화면마다 각자 부르는 대신 여기서 한 곳에만 걸어둔다).
class _MovieLogRouterApp extends StatefulWidget {
  const _MovieLogRouterApp();

  @override
  State<_MovieLogRouterApp> createState() => _MovieLogRouterAppState();
}

class _MovieLogRouterAppState extends State<_MovieLogRouterApp> {
  late final AuthViewModel _authViewModel;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authViewModel = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(_authViewModel);
    _authViewModel.addListener(_handleAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel.restoreSession();
    });
  }

  void _handleAuthChanged() {
    if (_authViewModel.status == AuthStatus.signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authViewModel.loadMember();
      });
    }
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_handleAuthChanged);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
