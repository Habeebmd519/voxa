import 'package:flutter/material.dart';

class ProfileShimmer extends StatefulWidget {
  const ProfileShimmer({super.key});

  @override
  State<ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<ProfileShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // 🎨 Theme (easy to reuse)
  static const _base = Color(0xFFE6EFE0);
  static const _highlight = Color(0xFFF6FBF2);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _animation = Tween<double>(
      begin: -1.2,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Core shimmer box ────────────────────────────────────────────────
  Widget _shimmer({
    double? width,
    required double height,
    double radius = 8,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(radius)
            : null,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.48, 0.52, 1.0],
          colors: const [_base, _highlight, _base, Color(0xFFDDEAD6)],
          transform: _SlidingGradientTransform(slidePercent: _animation.value),
        ),
      ),
    );
  }

  // White section shimmer
  Widget _shimmerWhite({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.48, 0.52, 1.0],
          colors: const [
            Color(0xFFEFF5E8),
            Color(0xFFFFFFFF),
            Color(0xFFEFF5E8),
            Color(0xFFE3EBDD),
          ],
          transform: _SlidingGradientTransform(slidePercent: _animation.value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SINGLE animation rebuild (performance fix)
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFB5D98A),

          body: Column(
            children: [
              // ── Profile Card ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A7A2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _shimmer(
                                width: 80,
                                height: 80,
                                shape: BoxShape.circle,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: _shimmer(
                                  width: 24,
                                  height: 24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _shimmer(width: 110, height: 18),
                                const SizedBox(height: 6),
                                _shimmer(width: 80, height: 12),
                                const SizedBox(height: 10),
                                _shimmer(width: 160, height: 28, radius: 14),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      Divider(color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _stat(),
                          _divider(),
                          _stat(),
                          _divider(),
                          _stat(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom Sheet ───────────────────────────────
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _field(),
                              const SizedBox(height: 12),
                              _field(),
                              const SizedBox(height: 12),
                              _field(),
                              const SizedBox(height: 12),
                              _field(),
                              const SizedBox(height: 24),

                              _shimmerWhite(
                                width: double.infinity,
                                height: 56,
                                radius: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _bottomNav(),
            ],
          ),
        );
      },
    );
  }

  // ─── Components ─────────────────────────────────────────

  Widget _stat() {
    return Expanded(
      child: Column(
        children: [
          _shimmer(width: 40, height: 18),
          const SizedBox(height: 5),
          _shimmer(width: 60, height: 10),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.15),
    );
  }

  Widget _field() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _shimmerWhite(width: 70, height: 11),
          _shimmerWhite(width: 110, height: 13),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (i) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _shimmerWhite(width: 26, height: 26),
              if (i == 3) ...[
                const SizedBox(height: 4),
                _shimmerWhite(width: 20, height: 3),
              ],
            ],
          );
        }),
      ),
    );
  }
}

// ─── Gradient animation ───────────────────────────────────
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
