import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/widgets/similar_movies_section.dart';

void main() {
  testWidgets('비슷한 영화를 탭하면 pushReplacement로 상세 화면이 교체된다', (
    tester,
  ) async {
    // 5주차부터 실제 MovieListScreen이 TMDB 네트워크를 호출하므로, 이
    // 테스트는 appRouter 대신 이 테스트에 필요한 /movies, /movies/:movieId
    // 만 담은 최소 GoRouter를 쓴다. /movies는 "뒤로가기 한 번이면 목록으로
    // 돌아간다"는 걸 확인할 자리만 필요해서 네트워크 없는 스텁 화면으로 둔다.
    final router = GoRouter(
      initialLocation: '/movies/under-the-starlight',
      routes: [
        GoRoute(
          path: '/movies',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('영화 목록'))),
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
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('별빛 아래 우리'), findsWidgets);

    final initialStackLength = router
        .routerDelegate
        .currentConfiguration
        .matches
        .length;

    final similarTileFinder = find.descendant(
      of: find.byType(SimilarMoviesSection),
      matching: find.text('네 번째 오후'),
    );

    await tester.dragUntilVisible(
      similarTileFinder,
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(similarTileFinder, findsOneWidget);

    await tester.tap(similarTileFinder);
    await tester.pumpAndSettle();

    // pushReplacement가 실제로 현재 화면을 교체했는지 콘텐츠로 확인한다.
    expect(find.text('네 번째 오후'), findsWidgets);

    final afterStackLength = router
        .routerDelegate
        .currentConfiguration
        .matches
        .length;
    expect(
      afterStackLength,
      initialStackLength,
      reason: 'pushReplacement는 스택 깊이를 늘리지 않아야 한다',
    );

    // push였다면 뒤로가기 한 번으로는 "별빛 아래 우리"로 돌아가겠지만,
    // pushReplacement는 그 화면을 스택에서 완전히 들어냈으므로
    // 뒤로가기 한 번이면 바로 영화 목록(스텁)으로 돌아가야 한다.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('영화 목록'), findsOneWidget);
    expect(find.text('비슷한 영화'), findsNothing);
  });
}
