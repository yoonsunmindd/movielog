/// 닉네임/이메일 중복 확인 응답. v5는 Wrapper 없이 바로 이 모양으로 내려준다.
class CheckResult {
  final bool available;

  const CheckResult({required this.available});

  factory CheckResult.fromJson(Map<String, dynamic> json) {
    return CheckResult(available: json['available'] as bool);
  }
}
