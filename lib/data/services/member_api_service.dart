import 'package:dio/dio.dart';
import '../models/member_info.dart';

class MemberApiService {
  final Dio _dio;

  MemberApiService(this._dio);

  Future<MemberInfo> fetchMe() async {
    final response = await _dio.get('/v7/members/me');
    return parseMemberInfo(response.data as Map<String, dynamic>);
  }

  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _dio.patch(
      '/v7/members/me',
      data: {'nickname': nickname},
    );
    return parseMemberInfo(response.data as Map<String, dynamic>);
  }
}
