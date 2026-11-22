import 'package:dio/dio.dart';
import '../models/check_result.dart';

class MemberCheckService {
  final Dio _dio;

  MemberCheckService(this._dio);

  Future<CheckResult> checkNickname(String nickname) async {
    final response = await _dio.get(
      '/members/nickname/${Uri.encodeComponent(nickname.trim())}',
    );
    return CheckResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CheckResult> checkEmail(String email) async {
    final response = await _dio.get(
      '/members/email/${Uri.encodeComponent(email.trim())}',
    );
    return CheckResult.fromJson(response.data as Map<String, dynamic>);
  }
}
