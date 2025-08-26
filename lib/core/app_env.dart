import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get tmdbBearer => dotenv.maybeGet('TMDB_BEARER') ?? '';
}