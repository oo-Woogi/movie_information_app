class MovieDetailDto {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final int? budget;
  final int? revenue;
  final int? runtime;
  final String? tagline;
  final double? popularity;
  final double? voteAverage;
  final int? voteCount;
  final List<String> genres;
  final List<String> productionCompanyLogos;

  MovieDetailDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.budget,
    required this.revenue,
    required this.runtime,
    required this.tagline,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    required this.productionCompanyLogos,
  });

  factory MovieDetailDto.fromJson(Map<String, dynamic> j) {
    final genres = (j['genres'] as List? ?? [])
        .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final logos = (j['production_companies'] as List? ?? [])
        .map((e) => (e as Map<String, dynamic>)['logo_path'] as String?)
        .whereType<String>()
        .toList();

    return MovieDetailDto(
      id: j['id'] ?? 0,
      title: j['title'] ?? '',
      overview: j['overview'] ?? '',
      posterPath: j['poster_path'] as String?,
      releaseDate: j['release_date'] as String?,
      budget: j['budget'] as int?,
      revenue: j['revenue'] as int?,
      runtime: j['runtime'] as int?,
      tagline: j['tagline'] as String?,
      popularity: (j['popularity'] as num?)?.toDouble(),
      voteAverage: (j['vote_average'] as num?)?.toDouble(),
      voteCount: j['vote_count'] as int?,
      genres: genres,
      productionCompanyLogos: logos,
    );
  }
}