import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import 'app_providers.dart';

final nowPlayingProvider = FutureProvider<List<Movie>>(
  (ref) => ref.read(movieRepositoryProvider).fetchNowPlayingMovies(),
);

final popularProvider = FutureProvider<List<Movie>>(
  (ref) => ref.read(movieRepositoryProvider).fetchPopularMovies(),
);

final topRatedProvider = FutureProvider<List<Movie>>(
  (ref) => ref.read(movieRepositoryProvider).fetchTopRatedMovies(),
);

final upcomingProvider = FutureProvider<List<Movie>>(
  (ref) => ref.read(movieRepositoryProvider).fetchUpcomingMovies(),
);

final movieDetailProvider = FutureProvider.family<MovieDetail, int>(
  (ref, id) => ref.read(movieRepositoryProvider).fetchMovieDetail(id),
);