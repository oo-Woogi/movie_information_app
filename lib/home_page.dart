import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'application/providers/movie_providers.dart';
import 'detail_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _bg = Color(0xFF0F1115);
  static const _card = Color(0xFF1A1D24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: CustomScrollView(
        slivers: [

          // 가장 인기있는 (nowPlaying 첫 번째를 히어로로 사용)
          const _SectionHeader('가장 인기있는'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ref.watch(nowPlayingProvider).maybeWhen(
                data: (movies) {
                  if (movies.isEmpty) return const _HeroPlaceholder(bg: _card);
                  final first = movies.first;
                  final tag = 'hero_main_${first.id}';
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailPage(
                          movieId: first.id,
                          heroTag: tag,
                          posterPath: first.posterPath,
                        ),
                      ),
                    ),
                    child: Hero(
                      tag: tag,
                      child: _HeroPoster(url: _full(first.posterPath), bg: _card),
                    ),
                  );
                },
                orElse: () => const _HeroPlaceholder(bg: _card),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          const _SectionHeader('현재 상영중'),
          SliverToBoxAdapter(
            child: _HorizontalList(
              asyncMovies: ref.watch(nowPlayingProvider),
              itemHeight: 180,
              cardBg: _card,
              tagPrefix: 'nowPlaying',
              ranked: false,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          const _SectionHeader('인기순'),
          SliverToBoxAdapter(
            child: _HorizontalList(
              asyncMovies: ref.watch(popularProvider),
              itemHeight: 180,
              cardBg: _card,
              tagPrefix: 'popular',
              ranked: true, // 숫자 오버레이
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          const _SectionHeader('평점 높은순'),
          SliverToBoxAdapter(
            child: _HorizontalList(
              asyncMovies: ref.watch(topRatedProvider),
              itemHeight: 180,
              cardBg: _card,
              tagPrefix: 'topRated',
              ranked: false,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          const _SectionHeader('개봉예정'),
          SliverToBoxAdapter(
            child: _HorizontalList(
              asyncMovies: ref.watch(upcomingProvider),
              itemHeight: 180,
              cardBg: _card,
              tagPrefix: 'upcoming',
              ranked: false,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    ),
  );
  }

  static String? _full(String? posterPath) =>
      posterPath == null ? null : '${Consts.imageBaseW500}$posterPath';
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      );
}

class _HorizontalList extends StatelessWidget {
  const _HorizontalList({
    required this.asyncMovies,
    required this.itemHeight,
    required this.cardBg,
    required this.tagPrefix,
    required this.ranked,
  });

  final AsyncValue<List<dynamic>> asyncMovies;
  final double itemHeight;
  final Color cardBg;
  final String tagPrefix;
  final bool ranked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: asyncMovies.when(
        data: (movies) {
          final items = movies.take(20).toList();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final m = items[index];
              final tag = 'poster_${tagPrefix}_${m.id}';
              final img = HomePage._full(m.posterPath);

              final card = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  height: itemHeight,
                  color: cardBg,
                  child: img == null
                      ? const _SkeletonFill(opacity: 0.06)
                      : Image.network(img, fit: BoxFit.cover),
                ),
              );

              if (!ranked) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        movieId: m.id,
                        heroTag: tag,
                        posterPath: m.posterPath,
                      ),
                    ),
                  ),
                  child: Hero(tag: tag, child: card),
                );
              }

              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailPage(
                      movieId: m.id,
                      heroTag: tag,
                      posterPath: m.posterPath,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 140, // 카드(120) + 랭킹 넘버 영역(20)
                  height: itemHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 카드: 왼쪽에 랭킹 영역을 두기 위해 약간 오른쪽으로 밀어 배치
                      Positioned(
                        left: 20,
                        top: 0,
                        child: Hero(tag: tag, child: card),
                      ),
                      // 랭킹 넘버: 기존 위치 유지하되 카드 위 레이어에 오도록 순서상 뒤에 둔다
                      Positioned(
                        left: 0,
                        bottom: -10,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: itemHeight * 0.5, // 카드 높이에 비례한 큰 사이즈
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.3,
                            letterSpacing: (index + 1) < 10 ? -2 : -4,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 2)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(width: 120, height: itemHeight, color: cardBg, child: const _SkeletonFill()),
          ),
        ),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e', style: const TextStyle(color: Colors.white70)),
        ),
      ),
    );
  }
}

class _HeroPoster extends StatelessWidget {
  const _HeroPoster({required this.url, required this.bg});
  final String? url;
  final Color bg;
  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: bg,
            child: url == null ? const _SkeletonFill(opacity: 0.06) : Image.network(url!, fit: BoxFit.cover),
          ),
        ),
      );
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.bg});
  final Color bg;
  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(color: bg, child: const _SkeletonFill(opacity: 0.06)),
        ),
      );
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
    final p = Paint()..color = Colors.white..strokeWidth = 16;
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