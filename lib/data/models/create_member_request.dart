/// 회원가입 요청 바디. email/nickname은 trim하지만 password는 그대로 보낸다.
class CreateMemberRequest {
  final String email;
  final String nickname;
  final String password;

  const CreateMemberRequest({
    required this.email,
    required this.nickname,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'nickname': nickname.trim(),
    'password': password,
  };
}
