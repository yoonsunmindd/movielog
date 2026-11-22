final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$');

class Validators {
  static String? nickname(String value) {
    if (value.isEmpty) return '닉네임을 입력해주세요.';
    if (value.length < 2) return '닉네임은 2자 이상 입력해주세요.';
    return null;
  }

  static String? email(String value) {
    if (value.isEmpty) return '이메일을 입력해주세요.';
    if (!_emailPattern.hasMatch(value)) return '올바른 이메일 형식이 아니에요.';
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return '비밀번호를 입력해주세요.';
    if (value.length < 8) return '비밀번호는 8자 이상 입력해주세요.';
    return null;
  }
}
