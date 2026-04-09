import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Drop-in shimmer for ChatScreen
//  Usage: show this while Firebase streams are
//  in ConnectionState.waiting
// ─────────────────────────────────────────────

class ChatShimmer extends StatefulWidget {
  const ChatShimmer({super.key});

  @override
  State<ChatShimmer> createState() => _ChatShimmerState();
}

class _ChatShimmerState extends State<ChatShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                children: [
                  // Received bubble
                  _ReceivedBubbleShimmer(shimmerX: _animation.value),
                  const SizedBox(height: 14),

                  // Premium Deal card skeleton
                  _DealCardShimmer(shimmerX: _animation.value),
                  const SizedBox(height: 14),

                  // Sent bubble
                  _SentBubbleShimmer(shimmerX: _animation.value, width: 130),
                  const SizedBox(height: 14),

                  // Received bubble
                  _ReceivedBubbleShimmer(shimmerX: _animation.value, width: 90),
                  const SizedBox(height: 14),

                  // Sent bubble (wider)
                  _SentBubbleShimmer(shimmerX: _animation.value, width: 190),
                  const SizedBox(height: 14),

                  // Received bubble (short)
                  _ReceivedBubbleShimmer(shimmerX: _animation.value, width: 70),
                ],
              ),
            ),

            // Input bar skeleton
            _InputBarShimmer(shimmerX: _animation.value),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
//  Internal shimmer building blocks
// ──────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double shimmerX;
  final double width;
  final double height;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerBox({
    required this.shimmerX,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor = const Color(0xFFE0ECD4),
    this.highlightColor = const Color(0xFFF2FAE8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(shimmerX - 1, 0),
          end: Alignment(shimmerX, 0),
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _DarkShimmerBox extends StatelessWidget {
  final double shimmerX;
  final double width;
  final double height;
  final double borderRadius;

  const _DarkShimmerBox({
    required this.shimmerX,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(shimmerX - 1, 0),
          end: Alignment(shimmerX, 0),
          colors: const [
            Color(0xFF2E2E2E),
            Color(0xFF3E3E3E),
            Color(0xFF2E2E2E),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _SentShimmerBox extends StatelessWidget {
  final double shimmerX;
  final double width;
  final double height;
  final double borderRadius;

  const _SentShimmerBox({
    required this.shimmerX,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(shimmerX - 1, 0),
          end: Alignment(shimmerX, 0),
          colors: const [
            Color(0xFF72AA3C),
            Color(0xFF8CC84E),
            Color(0xFF72AA3C),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ── Received bubble ────────────────────────────
class _ReceivedBubbleShimmer extends StatelessWidget {
  final double shimmerX;
  final double width;

  const _ReceivedBubbleShimmer({required this.shimmerX, this.width = 110});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar circle
        _ShimmerBox(
          shimmerX: shimmerX,
          width: 36,
          height: 36,
          borderRadius: 18,
        ),
        const SizedBox(width: 8),
        // Bubble
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0E0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(shimmerX: shimmerX, width: width - 40, height: 11),
              const SizedBox(height: 6),
              _ShimmerBox(
                shimmerX: shimmerX,
                width: 36,
                height: 9,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sent bubble ────────────────────────────────
class _SentBubbleShimmer extends StatelessWidget {
  final double shimmerX;
  final double width;

  const _SentBubbleShimmer({required this.shimmerX, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF7AB84A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SentShimmerBox(
                shimmerX: shimmerX,
                width: width - 40,
                height: 11,
              ),
              const SizedBox(height: 6),
              _SentShimmerBox(
                shimmerX: shimmerX,
                width: 46,
                height: 9,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Premium deal card ──────────────────────────
class _DealCardShimmer extends StatelessWidget {
  final double shimmerX;

  const _DealCardShimmer({required this.shimmerX});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + title + badge
          Row(
            children: [
              _DarkShimmerBox(
                shimmerX: shimmerX,
                width: 22,
                height: 22,
                borderRadius: 6,
              ),
              const SizedBox(width: 8),
              _DarkShimmerBox(
                shimmerX: shimmerX,
                width: 110,
                height: 13,
                borderRadius: 6,
              ),
              const Spacer(),
              _DarkShimmerBox(
                shimmerX: shimmerX,
                width: 58,
                height: 22,
                borderRadius: 11,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title line
          _DarkShimmerBox(
            shimmerX: shimmerX,
            width: 160,
            height: 13,
            borderRadius: 6,
          ),
          const SizedBox(height: 8),

          // Description line
          _DarkShimmerBox(
            shimmerX: shimmerX,
            width: 200,
            height: 11,
            borderRadius: 5,
          ),
          const SizedBox(height: 6),
          _DarkShimmerBox(
            shimmerX: shimmerX,
            width: 140,
            height: 11,
            borderRadius: 5,
          ),
          const SizedBox(height: 12),

          // Total price
          _DarkShimmerBox(
            shimmerX: shimmerX,
            width: 80,
            height: 13,
            borderRadius: 6,
          ),
          const SizedBox(height: 12),

          // Milestone row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DarkShimmerBox(
                    shimmerX: shimmerX,
                    width: double.infinity,
                    height: 11,
                    borderRadius: 5,
                  ),
                ),
                const SizedBox(width: 12),
                _DarkShimmerBox(
                  shimmerX: shimmerX,
                  width: 36,
                  height: 11,
                  borderRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DarkShimmerBox(
                    shimmerX: shimmerX,
                    width: double.infinity,
                    height: 11,
                    borderRadius: 5,
                  ),
                ),
                const SizedBox(width: 12),
                _DarkShimmerBox(
                  shimmerX: shimmerX,
                  width: 36,
                  height: 11,
                  borderRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status bar at bottom
          _DarkShimmerBox(
            shimmerX: shimmerX,
            width: double.infinity,
            height: 36,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────
class _InputBarShimmer extends StatelessWidget {
  final double shimmerX;

  const _InputBarShimmer({required this.shimmerX});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          _ShimmerBox(
            shimmerX: shimmerX,
            width: 45,
            height: 45,
            borderRadius: 22.5,
            baseColor: const Color(0xFF4A7A2A),
            highlightColor: const Color(0xFF5A9A3A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ShimmerBox(
              shimmerX: shimmerX,
              width: double.infinity,
              height: 45,
              borderRadius: 22.5,
            ),
          ),
          const SizedBox(width: 10),
          _ShimmerBox(
            shimmerX: shimmerX,
            width: 45,
            height: 45,
            borderRadius: 22.5,
            baseColor: const Color(0xFF4A7A2A),
            highlightColor: const Color(0xFF5A9A3A),
          ),
        ],
      ),
    );
  }
}
