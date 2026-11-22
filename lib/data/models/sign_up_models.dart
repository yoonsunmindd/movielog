/// 회원가입 성공 응답의 result.
class SignUpResult {
  final int memberId;
  final String email;
  final String nickname;

  const SignUpResult({
    required this.memberId,
    required this.email,
    required this.nickname,
  });

  factory SignUpResult.fromJson(Map<String, dynamic> json) {
    return SignUpResult(
      memberId: json['memberId'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
    );
  }
}
