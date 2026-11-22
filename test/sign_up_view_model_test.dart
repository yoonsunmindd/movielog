import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/view_models/submit_status.dart';

void main() {
  const request = CreateMemberRequest(
    email: 'a@example.com',
    nickname: '닉네임',
    password: 'Password123!',
  );

  test('400이고 메시지에 비밀번호가 있으면 passwordErrorText로 간다', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 400,
                data: {
                  'isSuccess': false,
                  'code': 'COMMON4001',
                  'message': '비밀번호 형식이 올바르지 않습니다',
                },
              ),
            ),
          );
        },
      ),
    );
    final viewModel = SignUpViewModel(SignUpService(dio));

    await viewModel.submit(request);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.passwordErrorText, '비밀번호 형식이 올바르지 않습니다');
    expect(viewModel.snackbarMessage, isNull);
  });

  test('409 중복 오류는 서버 메시지 그대로 snackbarMessage로 간다', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 409,
                data: {
                  'isSuccess': false,
                  'code': 'COMMON4091',
                  'message': '이미 가입된 이메일입니다',
                },
              ),
            ),
          );
        },
      ),
    );
    final viewModel = SignUpViewModel(SignUpService(dio));

    await viewModel.submit(request);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.snackbarMessage, '이미 가입된 이메일입니다');
    expect(viewModel.passwordErrorText, isNull);
  });

  test('result.memberId가 null이면 성공으로 처리하지 않는다', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'isSuccess': true,
                'code': 'COMMON200',
                'message': 'ok',
                'result': null,
              },
            ),
          );
        },
      ),
    );
    final viewModel = SignUpViewModel(SignUpService(dio));

    await viewModel.submit(request);

    expect(viewModel.submitStatus, SubmitStatus.error);
    expect(viewModel.createdMemberId, isNull);
  });
}
