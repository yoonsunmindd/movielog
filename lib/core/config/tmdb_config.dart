import 'package:flutter_dotenv/flutter_dotenv.dart';

/// TMDB 관련 설정값을 .env에서 읽어온다.
class TmdbConfig {
  TmdbConfig._();

  static String get accessToken => dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';
}
