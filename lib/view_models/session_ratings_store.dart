import 'package:flutter/foundation.dart';
import '../data/models/rating_dto.dart';

/// 현재 로그인 세션 동안 등록/수정/삭제한 평점을 메모리에 들고 있는다.
/// v7에는 토큰 기반 "내 평점 전체 조회"가 없어서, 재시작하면 비워진다.
/// 로그아웃/세션 만료/새 로그인 때는 AuthViewModel이 clear()를 호출해서
/// 이전 세션의 평점이 남지 않게 한다.
class SessionRatingsStore extends ChangeNotifier {
  List<RatingDto> ratings = [];

  void add(RatingDto rating) {
    ratings = [rating, ...ratings];
    notifyListeners();
  }

  void replace(RatingDto updated) {
    ratings = [
      for (final rating in ratings)
        rating.ratingId == updated.ratingId ? updated : rating,
    ];
    notifyListeners();
  }

  void remove(int ratingId) {
    ratings = ratings.where((rating) => rating.ratingId != ratingId).toList();
    notifyListeners();
  }

  void clear() {
    if (ratings.isEmpty) return;
    ratings = [];
    notifyListeners();
  }
}
