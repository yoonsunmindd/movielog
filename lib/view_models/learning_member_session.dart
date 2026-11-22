import 'package:flutter/foundation.dart';

/// 학습용으로 가입한 회원의 memberId를 세션 동안만 들고 있는다.
/// 영속화하지 않으므로 앱을 재시작하면 사라지고 다시 가입해야 한다.
class LearningMemberSession extends ChangeNotifier {
  int? memberId;

  void setMemberId(int id) {
    memberId = id;
    notifyListeners();
  }

  void clear() {
    memberId = null;
    notifyListeners();
  }
}
