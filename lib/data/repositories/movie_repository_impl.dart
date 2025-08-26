import 'package:movie_information_app/domain/entities/movie.dart';
import 'package:movie_information_app/domain/entities/movie_detail.dart';
import 'package:movie_information_app/domain/repositories/movie_repository.dart';
import '../datasource/movie_data_source.dart';
import '../dto/movie_response_dto.dart';
import '../dto/movie_detail_dto.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieDataSource _ds;
  MovieRepositoryImpl(this._ds);

  List<Movie> _mapList(MovieResponseDto dto) =>
      dto.results.map((e) => Movie(id: e.id, posterPath: e.posterPath)).toList();

  MovieDetail _mapDetail(MovieDetailDto d) => MovieDetail(
        id: d.id,
        title: d.title,
        overview: d.overview,
        posterPath: d.posterPath,
        releaseDate: d.releaseDate,
        budget: d.budget ?? 0,
        revenue: d.revenue ?? 0,
        runtime: d.runtime ?? 0,
        tagline: d.tagline ?? '',
        popularity: d.popularity ?? 0,
        voteAverage: d.voteAverage ?? 0,
        voteCount: d.voteCount ?? 0,
        genres: d.genres,
        productionCompanyLogos: d.productionCompanyLogos,
      );

  @override
  Future<List<Movie>> fetchNowPlayingMovies() async => _mapList(await _ds.fetchNowPlaying());

  @override
  Future<List<Movie>> fetchPopularMovies() async => _mapList(await _ds.fetchPopular());

  @override
  Future<List<Movie>> fetchTopRatedMovies() async => _mapList(await _ds.fetchTopRated());

  @override
  Future<List<Movie>> fetchUpcomingMovies() async => _mapList(await _ds.fetchUpcoming());

  @override
  Future<MovieDetail> fetchMovieDetail(int id) async => _mapDetail(await _ds.fetchDetail(id));
}