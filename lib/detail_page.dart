import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_information_app/core/constants.dart';
import 'package:movie_information_app/application/providers/movie_providers.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key, required this.movieId, required this.heroTag, this.posterPath});

  final int movieId;
  final String heroTag;          // HomePage에서 사용한 Hero tag와 반드시 동일해야 함
  final String? posterPath;      // TMDB poster_path (null 가능)

  static const Color _bg = Color(0xFF0F1115);
  static const Color _card = Color(0xFF1A1D24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero 포스터 영역 (2:3 비율)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Hero(
                  tag: heroTag,
                  flightShuttleBuilder: _flightBuilder,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _PosterImage(
                      url: posterPath == null ? null : '${Consts.imageBaseW500}$posterPath',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 상세 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: detail.when(
                data: (d) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if ((d.tagline).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        d.tagline,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (d.releaseDate != null && d.releaseDate!.isNotEmpty)
                          _Chip(text: _formatDate(d.releaseDate!)),
                        if (d.runtime > 0) _Chip(text: _formatRuntime(d.runtime)),
                        if (d.voteAverage > 0) _Chip(text: '⭐ ${d.voteAverage.toStringAsFixed(1)}'),
                        for (final g in d.genres) _Chip(text: g),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text('개요', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      d.overview.isEmpty ? '줄거리 정보가 없습니다.' : d.overview,
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    ),

                    const SizedBox(height: 20),
                    const Text('흥행정보', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    _HorizontalInfoList(children: [
                      _InfoTile(label: '평점', value: d.voteAverage > 0 ? d.voteAverage.toStringAsFixed(1) : '-'),
                      _InfoTile(label: '평점투표수', value: d.voteCount.toString()),
                      _InfoTile(label: '인기점수', value: d.popularity.toStringAsFixed(1)),
                    ]),

                    const SizedBox(height: 20),
                    const Text('제작사', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    _ProductionCompaniesList(logos: d.productionCompanyLogos),
                    const SizedBox(height: 24),
                  ],
                ),
                loading: () => const _DetailSkeleton(),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '불러오기 실패: $e',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hero 애니메이션 중 복행 위젯 스타일
  static Widget _flightBuilder(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero toHero = toHeroContext.widget as Hero;
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
      child: toHero.child,
    );
  }

  static String _formatRuntime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}분';
    return '${h}시간 ${m}분';
  }

  static String _formatDate(String yyyymmdd) {
    // 간단 포맷: 2025-08-25 -> 2025.08.25
    if (yyyymmdd.length >= 10) {
      return '${yyyymmdd.substring(0, 4)}.${yyyymmdd.substring(5, 7)}.${yyyymmdd.substring(8, 10)}';
    }
    return yyyymmdd;
  }

  static String _formatCurrency(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write(',');
    }
    return '\$${buf.toString()}';
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({this.url});
  final String? url;
  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const _SkeletonFill(opacity: 0.06);
    }
    return Image.network(url!, fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return const _SkeletonFill(opacity: 0.06);
    }, errorBuilder: (_, __, ___) => const _SkeletonFill(opacity: 0.06));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DetailPage._card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DetailPage._card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HorizontalInfoList extends StatelessWidget {
  const _HorizontalInfoList({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: children.length,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DetailPage._card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ProductionCompaniesList extends StatelessWidget {
  const _ProductionCompaniesList({required this.logos});
  final List<String> logos;

  @override
  Widget build(BuildContext context) {
    if (logos.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: logos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final path = logos[index];
          final String? url = path.isEmpty ? null : '${Consts.imageBaseW500}$path';
          return Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9), // 배경 흰색, 투명도 0.9
              borderRadius: BorderRadius.circular(12),
            ),
            child: url == null
                ? const SizedBox()
                : Image.network(url, fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SkeletonBar(width: 220, height: 22),
        SizedBox(height: 8),
        _SkeletonBar(width: 140, height: 14),
        SizedBox(height: 16),
        _SkeletonBar(width: double.infinity, height: 14),
        SizedBox(height: 8),
        _SkeletonBar(width: double.infinity, height: 14),
        SizedBox(height: 8),
        _SkeletonBar(width: 220, height: 14),
        SizedBox(height: 24),
      ],
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.width, required this.height});
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DetailPage._card,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SkeletonFill extends StatelessWidget {
  const _SkeletonFill({this.opacity = 0.08});
  final double opacity;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StripePainter(opacity: opacity));
}

class _StripePainter extends CustomPainter {
  _StripePainter({this.opacity = 0.08});
  final double opacity;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(opacity)..strokeWidth = 16;
    const gap = 28.0;
    double x = -size.height;
    while (x < size.width + size.height) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
      x += gap;
    }
  }
  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) => false;
}
