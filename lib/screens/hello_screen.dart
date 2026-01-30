import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:voxa/screens/main_screen.dart';

class ExpandingScreenFromButton extends StatefulWidget {
  final Offset buttonOffset; // start button position
  final Size buttonSize; // start button size
  final Offset endButtonOffset; // target button position (app bar)
  final Size endButtonSize; // target button size

  const ExpandingScreenFromButton({
    super.key,
    required this.buttonOffset,
    required this.buttonSize,
    required this.endButtonOffset,
    required this.endButtonSize,
  });

  @override
  State<ExpandingScreenFromButton> createState() =>
      _ExpandingScreenFromButtonState();
}

class _ExpandingScreenFromButtonState extends State<ExpandingScreenFromButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<Offset> _centerAnimation;

  late Offset _startCenter;
  late Offset _endCenter;
  late double _maxRadius;

  @override
  void initState() {
    super.initState();

    _startCenter =
        widget.buttonOffset +
        Offset(widget.buttonSize.width / 2, widget.buttonSize.height / 2);

    // Top-left corner (manual test)
    _endCenter = Offset(40, 40);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      // Compute max radius to cover entire screen
      final startDistances = [
        (_startCenter - Offset.zero).distance,
        (_startCenter - Offset(size.width, 0)).distance,
        (_startCenter - Offset(0, size.height)).distance,
        (_startCenter - Offset(size.width, size.height)).distance,
      ];

      final endDistances = [
        (_endCenter - Offset.zero).distance,
        (_endCenter - Offset(size.width, 0)).distance,
        (_endCenter - Offset(0, size.height)).distance,
        (_endCenter - Offset(size.width, size.height)).distance,
      ];

      _maxRadius = [...startDistances, ...endDistances].reduce(max);

      // Radius animation: grows forward, shrinks reverse
      _radiusAnimation = Tween<double>(begin: 0, end: _maxRadius).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );

      // Center animation: forward fixed, reverse moves to top-left
      _centerAnimation = Tween<Offset>(
        begin: _startCenter,
        end: _endCenter,
      ).animate(_controller);

      // Start expanding
      _controller.forward();

      // Wait 6 seconds then shrink
      Future.delayed(const Duration(seconds: 6), () {
        if (!mounted) return;
        _controller.reverse();
      });
    });

    // Navigate after reverse completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final center = _centerAnimation.value;
        final radius = _radiusAnimation.value;

        return ClipOval(
          clipper: CircleRevealClipper(center: center, radius: radius),
          child: Container(
            color: Colors.deepPurple,
            child: Stack(
              children: [
                Center(
                  child: Lottie.asset(
                    'assets/hello.json',
                    width: 300,
                    height: 300,
                    repeat: true,
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (!mounted) return;
                      _controller.stop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CircleRevealClipper extends CustomClipper<Rect> {
  final Offset center;
  final double radius;

  CircleRevealClipper({required this.center, required this.radius});

  @override
  Rect getClip(Size size) => Rect.fromCircle(center: center, radius: radius);

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) =>
      radius != oldClipper.radius || center != oldClipper.center;
}
