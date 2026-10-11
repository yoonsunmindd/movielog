import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/services/fake_movie_service.dart';
import 'package:movielog/widgets/movie_list_error.dart';
import 'package:movielog/widgets/movie_list_loading.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('로딩 -> 에러 -> 재시도 -> 성공 순서로 상태가 바뀐다', (tester) async {
    final service = FakeMovieService(
      mode: FakeMovieServiceMode.errorOnce,
      delay: const Duration(milliseconds: 10),
    );

    await tester.pumpWidget(
      MaterialApp(home: MovieListScreen(movieService: service)),
    );

    expect(find.byType(MovieListLoading), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(MovieListError), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    expect(find.byType(MovieListLoading), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsWidgets);
  });
}
