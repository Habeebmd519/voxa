import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/Drop/pressantation/bloc/friendCubit/freindCubit.dart';
import 'dart:math' as math;

import 'package:synapse/feature/auth/data/model/user_model.dart';

class FollowButton extends StatefulWidget {
  final bool initialFollowing;
  final bool compact;
  final ValueChanged<bool>? onChanged;

  final String targetUserId;
  final UserModel currentUser;

  const FollowButton({
    super.key,
    this.initialFollowing = false,
    this.compact = false,
    this.onChanged,
    required this.targetUserId,
    required this.currentUser,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
    with TickerProviderStateMixin {
  late bool _following;

  // Main press controller
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  // Shimmer / fill sweep on follow
  late AnimationController _fillCtrl;
  late Animation<double> _fillAnim;

  // Checkmark draw-on
  late AnimationController _checkCtrl;
  late Animation<double> _checkAnim;

  // Particle burst
  late AnimationController _burstCtrl;
  late Animation<double> _burstAnim;

  // Wiggle on unfollow
  late AnimationController _wiggleCtrl;
  late Animation<double> _wiggleAnim;

  // Label cross-fade
  late AnimationController _labelCtrl;
  late Animation<double> _labelAnim;

  @override
  void initState() {
    super.initState();

    _following = widget.currentUser.friendIds.contains(widget.targetUserId);

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));

    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fillAnim = CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOut);

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut);

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _burstAnim = CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOut);

    _wiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _wiggleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.06), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.06, end: 0.06), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.06, end: -0.04), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.04), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.04, end: 0), weight: 1),
    ]).animate(_wiggleCtrl);

    _labelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _labelAnim = CurvedAnimation(parent: _labelCtrl, curve: Curves.easeInOut);

    if (_following) {
      _fillCtrl.value = 1.0;
      _checkCtrl.value = 1.0;
      _labelCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _fillCtrl.dispose();
    _checkCtrl.dispose();
    _burstCtrl.dispose();
    _wiggleCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final nowFollowing = !_following;

    // 🔥 press animation
    await _pressCtrl.forward();
    _pressCtrl.reverse();

    // 🔥 UI update
    setState(() => _following = nowFollowing);
    widget.onChanged?.call(nowFollowing);

    // 🔥 FIRESTORE CALL (REAL LOGIC)
    context.read<FriendCubit>().toggleFriend(
      myId: widget.currentUser.uid,
      targetUserId: widget.targetUserId,
      context: context,
    );

    // 🔥 animations
    if (nowFollowing) {
      _burstCtrl.forward(from: 0);
      _fillCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 80));
      _checkCtrl.forward(from: 0);
      _labelCtrl.forward(from: 0);
    } else {
      _wiggleCtrl.forward(from: 0);
      _fillCtrl.reverse();
      _checkCtrl.reverse();
      _labelCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnim,
        _fillAnim,
        _checkAnim,
        _burstAnim,
        _wiggleAnim,
        _labelAnim,
      ]),
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Transform.rotate(
            angle: _wiggleAnim.value,
            child: GestureDetector(
              onTapDown: (_) => _pressCtrl.forward(),
              onTapCancel: () => _pressCtrl.reverse(),
              onTap: _toggle,
              child: widget.compact ? _buildCompact() : _buildPill(),
            ),
          ),
        );
      },
    );
  }

  // ── Pill (default) ────────────────────────────────────────────────
  Widget _buildPill() {
    final fill = _fillAnim.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow behind button when following
        if (fill > 0)
          Opacity(
            opacity: fill * 0.45,
            child: Container(
              width: 160,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6EE7B7),
                    blurRadius: 28 * fill,
                    spreadRadius: 2 * fill,
                  ),
                ],
              ),
            ),
          ),

        // Burst particles
        if (_burstAnim.value > 0 && _burstAnim.value < 1)
          _BurstParticles(progress: _burstAnim.value, radius: 52),

        // Main button body
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 148,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                // Background fill sweep
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FillPainter(
                      progress: fill,
                      followingColor: const Color(0xFF10B981),
                      unfollowingColor: Colors.transparent,
                      borderColor: fill < 0.5
                          ? Color.lerp(
                              const Color(0xFF3A3A4A),
                              const Color(0xFF10B981),
                              fill * 2,
                            )!
                          : const Color(0xFF10B981),
                    ),
                  ),
                ),

                // Label
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Checkmark (draws in)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CustomPaint(
                          painter: _CheckPainter(
                            progress: _checkAnim.value,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Animated label cross-fade
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // "Follow"
                          Opacity(
                            opacity: (1 - _labelAnim.value).clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, _labelAnim.value * -8),
                              // offset: Offset(0, 0),
                              child: const Text(
                                'InFriend',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          // "Following"
                          Opacity(
                            opacity: _labelAnim.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, (1 - _labelAnim.value) * 8),
                              child: const Text(
                                'Friend',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Compact icon-only ────────────────────────────────────────────
  Widget _buildCompact() {
    final fill = _fillAnim.value;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (fill > 0)
          Opacity(
            opacity: fill * 0.4,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6EE7B7),
                    blurRadius: 22 * fill,
                    spreadRadius: fill,
                  ),
                ],
              ),
            ),
          ),
        if (_burstAnim.value > 0 && _burstAnim.value < 1)
          _BurstParticles(progress: _burstAnim.value, radius: 30),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              const Color(0xFF1E1E2A),
              const Color(0xFF10B981),
              fill,
            ),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFF3A3A4A),
                const Color(0xFF10B981),
                fill,
              )!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: _following
                  ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey('check'),
                      color: Colors.white,
                      size: 20,
                    )
                  : const Icon(
                      Icons.add_rounded,
                      key: ValueKey('add'),
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Custom Painters
// ════════════════════════════════════════════════════════════════════

/// Sweeping fill + border
class _FillPainter extends CustomPainter {
  final double progress;
  final Color followingColor;
  final Color unfollowingColor;
  final Color borderColor;

  const _FillPainter({
    required this.progress,
    required this.followingColor,
    required this.unfollowingColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rr = size.height / 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(rr),
    );

    // Background
    final bgPaint = Paint()
      ..color = Color.lerp(const Color(0xFF1E1E2A), followingColor, progress)!;
    canvas.drawRRect(rect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(_FillPainter old) =>
      old.progress != progress || old.borderColor != borderColor;
}

/// Animated checkmark draw-on
class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _CheckPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color.withOpacity(progress.clamp(0.0, 1.0))
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Check path: two segments
    // Segment 1: bottom-left corner (short leg)  0 → 0.45
    // Segment 2: long leg up-right                0.45 → 1.0

    final path = Path();
    final p1 = Offset(w * 0.15, h * 0.52); // start
    final p2 = Offset(w * 0.42, h * 0.75); // mid (bottom of check)
    final p3 = Offset(w * 0.85, h * 0.28); // end (top right)

    if (progress <= 0.45) {
      final t = progress / 0.45;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(lerpDouble(p1.dx, p2.dx, t), lerpDouble(p1.dy, p2.dy, t));
    } else {
      final t = (progress - 0.45) / 0.55;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(lerpDouble(p2.dx, p3.dx, t), lerpDouble(p2.dy, p3.dy, t));
    }

    canvas.drawPath(path, paint);
  }

  double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

/// Burst of tiny particles flying outward
class _BurstParticles extends StatelessWidget {
  final double progress;
  final double radius;

  const _BurstParticles({
    super.key,
    required this.progress,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 3, radius * 3),
      painter: _BurstPainter(progress: progress, radius: radius),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double progress;
  final double radius;

  const _BurstPainter({required this.progress, required this.radius});

  static const _colors = [
    Color(0xFF10B981),
    Color(0xFF6EE7B7),
    Color(0xFF34D399),
    Color(0xFFA7F3D0),
    Color(0xFF059669),
    Color(0xFF6EE7B7),
    Color(0xFFD1FAE5),
    Color(0xFF10B981),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final count = _colors.length;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final dist = radius * 1.3 * Curves.easeOut.transform(progress);
      final opacity = (1.0 - Curves.easeIn.transform(progress)).clamp(0.0, 1.0);
      final dotSize = 4.5 * (1 - progress * 0.5);

      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist;

      canvas.drawCircle(
        Offset(x, y),
        dotSize,
        Paint()..color = _colors[i].withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}
