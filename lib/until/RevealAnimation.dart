import 'package:flutter/material.dart';

class RevealAnimation extends StatefulWidget {
  final Offset startPosition;
  final Size startSize;
  final Color color;
  final VoidCallback onFinish;

  const RevealAnimation({
    required this.startPosition,
    required this.startSize,
    required this.color,
    required this.onFinish,
  });

  @override
  State<RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<RevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    scale = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

    controller.forward().whenComplete(widget.onFinish);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(
          children: [
            Positioned(
              left: widget.startPosition.dx,
              top: widget.startPosition.dy,
              child: Transform.scale(
                scale: 1 + (scale.value * 20), // 👈 grows huge
                child: Container(
                  width: widget.startSize.width,
                  height: widget.startSize.height,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
