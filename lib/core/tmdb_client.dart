import 'package:dio/dio.dart';
import 'constants.dart';
import 'app_env.dart';

Dio createTmdbDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Consts.tmdbBaseUrl,
      headers: {'Authorization': 'Bearer ${AppEnv.tmdbBearer}'},
      queryParameters: {'language': Consts.langKo},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  return dio;
}