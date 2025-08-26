import 'package:movie_information_app/data/dto/movie_response_dto.dart';
import 'package:movie_information_app/data/dto/movie_detail_dto.dart';

abstract class MovieDataSource {
  Future<MovieResponseDto> fetchNowPlaying();
  Future<MovieResponseDto> fetchPopular();
  Future<MovieResponseDto> fetchTopRated();
  Future<MovieResponseDto> fetchUpcoming();
  Future<MovieDetailDto> fetchDetail(int id);
}