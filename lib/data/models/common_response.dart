/// 워크북 서버의 공용 응답 포맷. result가 null이면 fromJsonT를 호출하지 않는다.
class CommonResponse<T> {
  final bool isSuccess;
  final String code;
  final String message;
  final T? result;

  const CommonResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  factory CommonResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawResult = json['result'];
    return CommonResponse<T>(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: rawResult == null
          ? null
          : fromJsonT(rawResult as Map<String, dynamic>),
    );
  }
}
