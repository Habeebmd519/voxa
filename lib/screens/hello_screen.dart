import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:voxa/core/network/genarate_defualt_profile_photo/get_gravatar_url.dart';
import 'package:voxa/screens/main_screen.dart';
import 'package:voxa/screens/screen_login.dart';

class ExpandingScreenFromButton extends StatefulWidget {
  final Offset buttonOffset; // start button position
  final Size buttonSize; // start button size
  // final Offset endButtonOffset; // target button position (app bar)
  // final Size endButtonSize; // target button size

  final email;

  const ExpandingScreenFromButton({
    super.key,
    required this.buttonOffset,
    required this.buttonSize,
    required this.email,
    // required this.endButtonOffset,
    // required this.endButtonSize,
  });

  @override
  State<ExpandingScreenFromButton> createState() =>
      _ExpandingScreenFromButtonState();
}

class _ExpandingScreenFromButtonState extends State<ExpandingScreenFromButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<Offset> _forwardCenter;
  late Animation<Offset> _reverseCenter;

  late Offset _startCenter;
  late Offset _endCenter;
  late double _maxRadius;

  bool _showMainScreen = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final gravatarUrl = getGravatarUrl(widget.email);
    _startCenter =
        widget.buttonOffset +
        Offset(widget.buttonSize.width / 2, widget.buttonSize.height / 2);

    // _endCenter =
    //     widget.endButtonOffset +
    //     Offset(widget.endButtonSize.width / 2, widget.endButtonSize.height / 2);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      _forwardCenter = ConstantTween<Offset>(_startCenter).animate(_controller);

      // Shrink toward top-left corner
      _endCenter = const Offset(20, 50);

      _reverseCenter = Tween<Offset>(
        begin: _startCenter,
        end: _endCenter,
      ).animate(ReverseAnimation(_controller));

      // Compute max radius
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

      _radiusAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeOut,
      );

      setState(() => _ready = true); // Start expanding
      _controller.forward();

      // Show MainScreen after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() {
          _showMainScreen = true;
        });
      });

      // Reverse after 6 seconds
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
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MainScreen(profUrl: gravatarUrl),
          ),
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
    if (!_ready) {
      return const SizedBox.shrink(); // or loading screen
    }
    return Stack(
      children: [
        // MainScreen behind the animation
        if (!_showMainScreen) AnimatedLoginScreen(),
        if (_showMainScreen) MainScreen(),

        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final center = _controller.status == AnimationStatus.reverse
                ? _reverseCenter.value
                : _forwardCenter.value;
            final radius = _radiusAnimation.value * _maxRadius;

            return ClipOval(
              clipper: CircleRevealClipper(center: center, radius: radius),
              child: Container(
                color: Color.fromARGB(255, 79, 127, 47),
                child: Stack(
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/hello.json',
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
