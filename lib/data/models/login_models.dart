/// 로그인 요청 바디. email은 trim하지만 password는 그대로 보낸다.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'password': password,
  };
}

/// 로그인 성공 응답의 result. v7은 memberId를 돌려주지 않는다.
class LoginResult {
  final String nickname;
  final String accessToken;

  const LoginResult({required this.nickname, required this.accessToken});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      nickname: json['nickname'] as String,
      accessToken: json['accessToken'] as String,
    );
  }
}
