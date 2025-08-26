class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final int budget;
  final int revenue;
  final int runtime;
  final String tagline;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final List<String> genres;
  final List<String> productionCompanyLogos;

  MovieDetail({
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
}