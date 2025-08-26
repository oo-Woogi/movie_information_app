import 'package:dio/dio.dart';
import 'package:movie_information_app/data/dto/movie_response_dto.dart';
import 'package:movie_information_app/data/dto/movie_detail_dto.dart';
import 'movie_data_source.dart';

class TmdbMovieDataSource implements MovieDataSource {
  final Dio _dio;
  TmdbMovieDataSource(this._dio);

  @override
  Future<MovieResponseDto> fetchNowPlaying() async =>
      MovieResponseDto.fromJson((await _dio.get('/movie/now_playing', queryParameters: {'page': 1})).data);

  @override
  Future<MovieResponseDto> fetchPopular() async =>
      MovieResponseDto.fromJson((await _dio.get('/movie/popular', queryParameters: {'page': 1})).data);

  @override
  Future<MovieResponseDto> fetchTopRated() async =>
      MovieResponseDto.fromJson((await _dio.get('/movie/top_rated', queryParameters: {'page': 1})).data);

  @override
  Future<MovieResponseDto> fetchUpcoming() async =>
      MovieResponseDto.fromJson((await _dio.get('/movie/upcoming', queryParameters: {'page': 1})).data);

  @override
  Future<MovieDetailDto> fetchDetail(int id) async =>
      MovieDetailDto.fromJson((await _dio.get('/movie/$id')).data);
}