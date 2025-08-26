import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/tmdb_client.dart';
import '../../data/datasource/movie_data_source.dart';
import '../../data/datasource/tmdb_movie_data_source.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';

final dioProvider = Provider<Dio>((ref) => createTmdbDio());
final dataSourceProvider = Provider<MovieDataSource>(
  (ref) => TmdbMovieDataSource(ref.read(dioProvider)),
);
final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepositoryImpl(ref.read(dataSourceProvider)),
);