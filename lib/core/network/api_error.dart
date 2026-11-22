import 'package:dio/dio.dart';

/// 서버 공용 응답({isSuccess, code, message, result})의 code를 꺼낸다.
/// 바디를 못 읽으면 null을 돌려준다.
String? apiErrorCode(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['code'] is String) {
    return data['code'] as String;
  }
  return null;
}

/// 서버 message를 그대로 쓰고, 파싱할 수 없으면 기본 문구를 돌려준다.
String apiErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return '요청을 처리하지 못했어요. 다시 시도해 주세요.';
}

/// accessToken이 만료/무효해서 세션을 정리해야 하는 코드인지.
bool isAuthExpiredCode(String? code) {
  return code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
}
