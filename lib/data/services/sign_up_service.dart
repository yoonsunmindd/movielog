import 'package:dio/dio.dart';
import '../models/check_result.dart';
import '../models/common_response.dart';
import '../models/create_member_request.dart';
import '../models/sign_up_models.dart';

class SignUpService {
  final Dio _dio;

  SignUpService(this._dio);

  Future<CheckResult> checkNickname(String nickname) async {
    final response = await _dio.get(
      '/v6/members/nickname/${Uri.encodeComponent(nickname.trim())}',
    );
    return CheckResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CheckResult> checkEmail(String email) async {
    final response = await _dio.get(
      '/v6/members/email/${Uri.encodeComponent(email.trim())}',
    );
    return CheckResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await _dio.post('/v6/members', data: request.toJson());
    return CommonResponse.fromJson(
      response.data as Map<String, dynamic>,
      SignUpResult.fromJson,
    );
  }
}

/// 서버 message를 그대로 쓰고, 파싱할 수 없으면 기본 문구를 돌려준다.
String writeSignUpErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return '회원가입에 실패했어요. 다시 시도해 주세요.';
}
