import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';

void main() {
  /// 실제 네트워크를 타지 않고 항상 "사용 가능" 응답을 돌려주는 가짜 Dio.
  Dio fakeAvailableDio() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'available': true},
            ),
          );
        },
      ),
    );
    return dio;
  }

  Future<void> pumpSignUpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SignUpViewModel>(
          create: (_) =>
              SignUpViewModel(SignUpService(fakeAvailableDio())),
          child: const SignUpScreen(),
        ),
      ),
    );
  }

  testWidgets('입력 전에는 오류 메시지와 검증 아이콘이 보이지 않는다', (tester) async {
    await pumpSignUpScreen(tester);

    expect(find.text('닉네임은 2~12자로 입력해주세요.'), findsNothing);
    expect(find.text('올바른 이메일 형식이 아니에요.'), findsNothing);
    expect(find.text('비밀번호는 8자 이상 입력해주세요.'), findsNothing);

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, '가입하기'),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('유효하지 않은 값 입력 시 한국어 오류 메시지가 표시된다', (tester) async {
    await pumpSignUpScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'a');
    await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
    await tester.enterText(find.byType(TextFormField).at(2), 'short');
    await tester.pump();

    expect(find.text('닉네임은 2~12자로 입력해주세요.'), findsOneWidget);
    expect(find.text('올바른 이메일 형식이 아니에요.'), findsOneWidget);
    expect(find.text('비밀번호는 8자 이상 입력해주세요.'), findsOneWidget);
  });

  testWidgets('닉네임/이메일 중복 확인을 통과하고 약관에 동의하면 가입 버튼이 활성화된다', (
    tester,
  ) async {
    await pumpSignUpScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), '무비러버');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'movie@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Password123!');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, '중복 확인').at(0));
    await tester.tap(find.widgetWithText(ElevatedButton, '중복 확인').at(1));
    await tester.pumpAndSettle();

    expect(find.text('사용 가능한 닉네임입니다.'), findsOneWidget);
    expect(find.text('사용 가능한 이메일입니다.'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final submitButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, '가입하기'),
    );
    expect(submitButton.onPressed, isNotNull);
  });

  testWidgets('넓은 화면에서는 폼이 최대 560 너비로 제한된다', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSignUpScreen(tester);

    final maxWidths = tester
        .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
        .map((box) => box.constraints.maxWidth);
    expect(maxWidths, contains(560));
  });
}
