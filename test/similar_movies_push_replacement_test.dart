import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:movielog/router/app_router.dart';
import 'package:movielog/widgets/similar_movies_section.dart';

void main() {
  setUp(() {
    // 중첩 라우트라 /movies/:id로 이동해도 부모 MovieListScreen이 함께
    // 빌드되고, 거기서 SharedPreferencesAsync를 쓰므로 플랫폼을 세팅해줘야 한다.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('비슷한 영화를 탭하면 pushReplacement로 상세 화면이 교체된다', (
    tester,
  ) async {
    appRouter.go('/movies/under-the-starlight');
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    await tester.pumpAndSettle();

    expect(find.text('별빛 아래 우리'), findsWidgets);

    final initialStackLength = appRouter
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

    final afterStackLength = appRouter
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
    // 뒤로가기 한 번이면 바로 영화 목록으로 돌아가야 한다.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('영화'), findsWidgets);
    expect(find.text('비슷한 영화'), findsNothing);
  });
}
