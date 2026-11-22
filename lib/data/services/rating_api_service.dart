import 'package:dio/dio.dart';
import '../models/rating_dto.dart';

class RatingApiService {
  final Dio _dio;

  RatingApiService(this._dio);

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/members/$memberId/ratings');
    return (response.data as List<dynamic>)
        .map((json) => RatingDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

String writeMyRatingsErrorMessage(DioException e) {
  switch (e.response?.statusCode) {
    case 400:
      return '요청이 올바르지 않아요.';
    case 404:
      return '사용자를 찾을 수 없어요.';
    default:
      return '평점을 불러오지 못했어요.';
  }
}
