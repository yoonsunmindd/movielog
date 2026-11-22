import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/view_models/auth_view_model.dart';

void main() {
  test('initializing/retryRequired은 /start만 허용한다', () {
    expect(authRedirect(AuthStatus.initializing, '/start'), isNull);
    expect(authRedirect(AuthStatus.initializing, '/home'), '/start');
    expect(authRedirect(AuthStatus.retryRequired, '/login'), '/start');
    expect(authRedirect(AuthStatus.retryRequired, '/start'), isNull);
  });

  test('signedOut/authenticating은 공개 경로(/login, /signup)만 허용한다', () {
    expect(authRedirect(AuthStatus.signedOut, '/login'), isNull);
    expect(authRedirect(AuthStatus.signedOut, '/signup'), isNull);
    expect(authRedirect(AuthStatus.signedOut, '/home'), '/login');
    expect(authRedirect(AuthStatus.signedOut, '/my/ratings'), '/login');
    expect(authRedirect(AuthStatus.authenticating, '/movies'), '/login');
  });

  test('signedIn은 /start와 공개 경로를 홈으로 보내고, 그 외는 그대로 둔다', () {
    expect(authRedirect(AuthStatus.signedIn, '/start'), '/home');
    expect(authRedirect(AuthStatus.signedIn, '/login'), '/home');
    expect(authRedirect(AuthStatus.signedIn, '/signup'), '/home');
    expect(authRedirect(AuthStatus.signedIn, '/movies'), isNull);
    expect(authRedirect(AuthStatus.signedIn, '/my/ratings'), isNull);
  });
}
