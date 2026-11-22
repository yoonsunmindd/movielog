final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$');
final RegExp _lowercasePattern = RegExp(r'[a-z]');
final RegExp _uppercasePattern = RegExp(r'[A-Z]');
final RegExp _digitPattern = RegExp(r'[0-9]');
final RegExp _specialCharPattern = RegExp(r'[!@#$%^&*]');

class Validators {
  static String? nickname(String value) {
    if (value.isEmpty) return '닉네임을 입력해주세요.';
    if (value.length < 2 || value.length > 12) {
      return '닉네임은 2~12자로 입력해주세요.';
    }
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
    if (!_lowercasePattern.hasMatch(value) ||
        !_uppercasePattern.hasMatch(value) ||
        !_digitPattern.hasMatch(value) ||
        !_specialCharPattern.hasMatch(value)) {
      return '비밀번호는 대/소문자, 숫자, 특수문자(!@#\$%^&*)를 각 1개 이상 포함해야 해요.';
    }
    return null;
  }
}
