import 'common_response.dart';

/// 내 정보 응답.
class MemberInfo {
  final String email;
  final String nickname;
  final DateTime createdAt;

  const MemberInfo({
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  MemberInfo copyWith({String? nickname}) {
    return MemberInfo(
      email: email,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt,
    );
  }
}

MemberInfo parseMemberInfo(Map<String, dynamic> json) {
  final response = CommonResponse.fromJson(json, MemberInfo.fromJson);
  final result = response.result;
  if (result == null) {
    throw StateError('내 정보 응답에 result가 없습니다.');
  }
  return result;
}
