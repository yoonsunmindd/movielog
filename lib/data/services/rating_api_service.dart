import 'package:dio/dio.dart';
import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  final Dio _publicDio;
  final Dio _authDio;

  RatingApiService(this._publicDio, this._authDio);

  /// 공개 평점 목록 조회. v7 로그인 응답에는 memberId가 없어서 이번 주차
  /// 기능(세션 평점)에서는 이 경로를 호출하지 않는다. 다른 회원의 공개
  /// 평점을 보여줄 화면이 생기면 그때 쓴다.
  Future<List<RatingDto>> fetchMemberRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');
    return (response.data as List<dynamic>)
        .map((json) => RatingDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post('/v7/ratings', data: request.toJson());
    return _parseRating(response.data as Map<String, dynamic>);
  }

  /// comment를 생략하면 서버가 기존 후기를 null로 덮어쓰기 때문에, score와
  /// comment를 항상 함께 보낸다.
  Future<RatingDto> updateRating(
    int ratingId,
    int score,
    String? comment,
  ) async {
    final response = await _authDio.patch(
      '/v7/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    return _parseRating(response.data as Map<String, dynamic>);
  }

  /// 삭제 성공은 204가 아니라 200(result 없음)이라 바디를 파싱하지 않는다.
  Future<void> deleteRating(int ratingId) async {
    await _authDio.delete('/v7/ratings/$ratingId');
  }

  RatingDto _parseRating(Map<String, dynamic> json) {
    final response = CommonResponse.fromJson(json, RatingDto.fromJson);
    final result = response.result;
    if (result == null) {
      throw StateError('평점 응답에 result가 없습니다.');
    }
    return result;
  }
}
