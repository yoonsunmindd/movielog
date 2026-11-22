import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// accessToken 저장소. 값 자체를 로그/주석/에러 문구에 남기지 않는다.
abstract class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> deleteAccessToken();
}

class SecureTokenStorage implements TokenStorage {
  static const _key = 'movielog.access_token';

  final FlutterSecureStorage _storage;

  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _key, value: token);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _key);
  }

  @override
  Future<void> deleteAccessToken() {
    return _storage.delete(key: _key);
  }
}
