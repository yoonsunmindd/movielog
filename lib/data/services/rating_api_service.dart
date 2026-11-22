import 'package:dio/dio.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  final Dio _dio;

  RatingApiService(this._dio);

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v6/members/$memberId/ratings');
    return (response.data as List<dynamic>)
        .map((json) => RatingDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 201만 확인한다. Swagger 설명과 예시 응답이 서로 달라 result 계약이
  /// 불확실해서, result는 파싱하지 않는다.
  Future<void> createRating(int memberId, CreateRatingRequest request) async {
    await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
  }

  /// comment를 생략하면 서버가 기존 후기를 null로 덮어쓰기 때문에, score와
  /// comment를 항상 함께 보낸다.
  Future<void> updateRating(
    int memberId,
    int ratingId,
    int score,
    String? comment,
  ) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
  }

  Future<void> deleteRating(int memberId, int ratingId) async {
    await _dio.delete('/v6/members/$memberId/ratings/$ratingId');
  }
}

/// 서버 message를 그대로 쓰고, 파싱할 수 없으면 기본 문구를 돌려준다.
String writeErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return '요청을 처리하지 못했어요. 다시 시도해 주세요.';
}

/// code가 COMMON403/COMMON404일 때만 재조회가 필요하다고 판단한다.
bool shouldRefreshAfterRatingError(DioException e) {
  final data = e.response?.data;
  final code = (data is Map) ? data['code'] as String? : null;
  return code == 'COMMON403' || code == 'COMMON404';
}
