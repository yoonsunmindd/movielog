import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';
import 'package:movielog/view_models/session_ratings_store.dart';

class _FakeTokenStorage implements TokenStorage {
  String? token = 'token-abc';

  @override
  Future<void> saveAccessToken(String token) async => this.token = token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async => token = null;
}

final _member = MemberInfo(
  email: 'a@example.com',
  nickname: '무비러버',
  createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
);

AuthViewModel _signedInAuthViewModel(TokenStorage tokenStorage) {
  final authViewModel = AuthViewModel(
    AuthApiService(Dio()),
    MemberApiService(Dio()),
    tokenStorage,
    SessionRatingsStore(),
  );
  authViewModel.status = AuthStatus.signedIn;
  authViewModel.member = _member;
  return authViewModel;
}

Dio _rejectingDio(String code, int statusCode) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: statusCode,
              data: {'isSuccess': false, 'code': code, 'message': '이미 사용 중인 닉네임이에요.'},
            ),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test('MEMBER409_1은 nicknameError로 가고 입력값은 유지된다', () async {
    final tokenStorage = _FakeTokenStorage();
    final authViewModel = _signedInAuthViewModel(tokenStorage);
    final viewModel = EditProfileViewModel(
      MemberApiService(_rejectingDio('MEMBER409_1', 409)),
      authViewModel,
      _member,
    );

    await viewModel.save('새닉네임');

    expect(viewModel.status, EditProfileStatus.failure);
    expect(viewModel.nicknameError, '이미 사용 중인 닉네임이에요.');
    expect(authViewModel.status, AuthStatus.signedIn);
  });

  test('현재 닉네임과 같으면 요청을 보내지 않고 성공 처리한다', () async {
    var requested = false;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requested = true;
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ),
    );
    final authViewModel = _signedInAuthViewModel(_FakeTokenStorage());
    final viewModel = EditProfileViewModel(
      MemberApiService(dio),
      authViewModel,
      _member,
    );

    await viewModel.save(_member.nickname);

    expect(viewModel.status, EditProfileStatus.success);
    expect(requested, isFalse);
  });

  test('401이면 세션을 만료시킨다', () async {
    final tokenStorage = _FakeTokenStorage();
    final authViewModel = _signedInAuthViewModel(tokenStorage);
    final viewModel = EditProfileViewModel(
      MemberApiService(_rejectingDio('AUTH401_3', 401)),
      authViewModel,
      _member,
    );

    await viewModel.save('새닉네임');

    expect(authViewModel.status, AuthStatus.signedOut);
    expect(authViewModel.sessionExpired, isTrue);
    expect(tokenStorage.token, isNull);
  });

  test('통신 오류는 로그아웃하지 않는다', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          );
        },
      ),
    );
    final tokenStorage = _FakeTokenStorage();
    final authViewModel = _signedInAuthViewModel(tokenStorage);
    final viewModel = EditProfileViewModel(
      MemberApiService(dio),
      authViewModel,
      _member,
    );

    await viewModel.save('새닉네임');

    expect(viewModel.status, EditProfileStatus.failure);
    expect(viewModel.message, '네트워크 상태를 확인하고 다시 시도해 주세요.');
    expect(authViewModel.status, AuthStatus.signedIn);
    expect(tokenStorage.token, isNotNull);
  });
}
