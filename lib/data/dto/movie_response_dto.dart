class MovieDto {
  final int id;
  final String? posterPath;

  MovieDto({required this.id, required this.posterPath});

  factory MovieDto.fromJson(Map<String, dynamic> j) =>
      MovieDto(id: j['id'] ?? 0, posterPath: j['poster_path'] as String?);
}

class MovieResponseDto {
  final int page;
  final List<MovieDto> results;

  MovieResponseDto({required this.page, required this.results});

  factory MovieResponseDto.fromJson(Map<String, dynamic> j) => MovieResponseDto(
        page: j['page'] ?? 1,
        results: (j['results'] as List? ?? [])
            .map((e) => MovieDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}