import 'package:dio/dio.dart';
import '../models/common_response.dart';
import '../models/login_models.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<LoginResult> login(LoginRequest request) async {
    final response = await _dio.post(
      '/v7/auth/login',
      data: request.toJson(),
    );
    final parsed = CommonResponse.fromJson(
      response.data as Map<String, dynamic>,
      LoginResult.fromJson,
    );
    final result = parsed.result;
    if (result == null) {
      throw StateError('로그인 응답에 result가 없습니다.');
    }
    return result;
  }
}
