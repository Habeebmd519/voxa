import 'dart:math';
import 'package:flutter/material.dart';

// ─── Splash Screen ────────────────────────────────────────────────────────────

class SynapseSplashScreen extends StatefulWidget {
  const SynapseSplashScreen({super.key});

  @override
  State<SynapseSplashScreen> createState() => _SynapseSplashScreenState();
}

class _SynapseSplashScreenState extends State<SynapseSplashScreen>
    with TickerProviderStateMixin {
  // Float animation for logo
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  // Ring rotation
  late AnimationController _ring1Controller;
  late AnimationController _ring2Controller;

  // Orb float controllers
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late AnimationController _orb4Controller;

  // Fade-in for content
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Tagline pulse
  late AnimationController _taglineController;
  late Animation<double> _taglineAnim;

  // Loading bar
  late AnimationController _loadController;
  late Animation<double> _loadAnim;

  // Glow pulse
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _ring1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _ring2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: false);

    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _orb4Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _taglineAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeInOut),
    );

    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _loadAnim = CurvedAnimation(parent: _loadController, curve: Curves.easeIn);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _ring1Controller.dispose();
    _ring2Controller.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _orb4Controller.dispose();
    _fadeController.dispose();
    _taglineController.dispose();
    _loadController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D1F),
      body: Stack(
        children: [
          // Background glow blobs
          _BackgroundGlows(glowAnim: _glowAnim),

          // Stars
          const _Stars(),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: _LogoWidget(
                          ring1: _ring1Controller,
                          ring2: _ring2Controller,
                          orb1: _orb1Controller,
                          orb2: _orb2Controller,
                          orb3: _orb3Controller,
                          orb4: _orb4Controller,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App name
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFC4B5FD),
                          Color(0xFFFFFFFF),
                          Color(0xFF93C5FD),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Synapse',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Divider
                    Container(
                      width: 48,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF7C3AED),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    FadeTransition(
                      opacity: _taglineAnim,
                      child: const Text(
                        'CONNECT · CHAT · CLOSE',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 3,
                          color: Color(0xFF6B7DB3),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading bar
                    _LoadingBar(loadAnim: _loadAnim),

                    const SizedBox(height: 10),

                    const Text(
                      'Loading your drops…',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3D507A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background Glows ─────────────────────────────────────────────────────────

class _BackgroundGlows extends StatelessWidget {
  final Animation<double> glowAnim;
  const _BackgroundGlows({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _GlowBlob(
              size: 300,
              color: const Color(0xFF3B0FA8).withOpacity(0.25 * glowAnim.value),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: _GlowBlob(
              size: 260,
              color: const Color(0xFF0F3A88).withOpacity(0.25 * glowAnim.value),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: _GlowBlob(
                size: 200,
                color: const Color(
                  0xFF2A0A60,
                ).withOpacity(0.18 * glowAnim.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }
}

// ─── Stars ────────────────────────────────────────────────────────────────────

class _Stars extends StatelessWidget {
  const _Stars();

  @override
  Widget build(BuildContext context) {
    final stars = [
      _StarData(top: 0.12, left: 0.20, size: 2.0, delay: 0),
      _StarData(top: 0.25, left: 0.75, size: 1.5, delay: 800),
      _StarData(top: 0.70, left: 0.15, size: 2.0, delay: 1200),
      _StarData(top: 0.80, left: 0.80, size: 1.0, delay: 400),
      _StarData(top: 0.45, left: 0.90, size: 2.0, delay: 1500),
      _StarData(top: 0.60, left: 0.05, size: 1.5, delay: 900),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: stars
            .map(
              (s) => Positioned(
                top: s.top * constraints.maxHeight,
                left: s.left * constraints.maxWidth,
                child: _PulsingDot(size: s.size, delay: s.delay),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StarData {
  final double top, left, size;
  final int delay;
  const _StarData({
    required this.top,
    required this.left,
    required this.size,
    required this.delay,
  });
}

class _PulsingDot extends StatefulWidget {
  final double size;
  final int delay;
  const _PulsingDot({required this.size, required this.delay});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );
    _anim = Tween<double>(
      begin: 0.25,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Logo Widget ──────────────────────────────────────────────────────────────

class _LogoWidget extends StatelessWidget {
  final AnimationController ring1;
  final AnimationController ring2;
  final AnimationController orb1;
  final AnimationController orb2;
  final AnimationController orb3;
  final AnimationController orb4;

  const _LogoWidget({
    required this.ring1,
    required this.ring2,
    required this.orb1,
    required this.orb2,
    required this.orb3,
    required this.orb4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring 1
          RotationTransition(
            turns: ring1,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.35),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Ring 2 (reverse)
          RotationTransition(
            turns: Tween<double>(begin: 1, end: 0).animate(ring2),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.28),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Core icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4F46E5),
                  Color(0xFF7C3AED),
                  Color(0xFFA855F7),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                  blurRadius: 32,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.15),
                  blurRadius: 64,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),

          // Orbs around the rings
          _OrbWidget(
            controller: orb1,
            color: const Color(0xFF06B6D4),
            size: 14,
            baseOffset: const Offset(0, -60),
          ),
          _OrbWidget(
            controller: orb2,
            color: const Color(0xFFA855F7),
            size: 10,
            baseOffset: const Offset(60, 0),
          ),
          _OrbWidget(
            controller: orb3,
            color: const Color(0xFF38BDF8),
            size: 12,
            baseOffset: const Offset(-52, 36),
          ),
          _OrbWidget(
            controller: orb4,
            color: const Color(0xFFE879F9),
            size: 8,
            baseOffset: const Offset(40, 44),
          ),
        ],
      ),
    );
  }
}

class _OrbWidget extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final Offset baseOffset;

  const _OrbWidget({
    required this.controller,
    required this.color,
    required this.size,
    required this.baseOffset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final dy = -8.0 * (controller.value - 0.5).abs() * 2 + 4;
        return Transform.translate(
          offset: Offset(baseOffset.dx, baseOffset.dy + dy),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Loading Bar ──────────────────────────────────────────────────────────────

class _LoadingBar extends StatelessWidget {
  final Animation<double> loadAnim;
  const _LoadingBar({required this.loadAnim});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Track
            Container(color: const Color(0xFF1A2240)),

            // Fill
            AnimatedBuilder(
              animation: loadAnim,
              builder: (_, __) => FractionallySizedBox(
                widthFactor: loadAnim.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4F46E5),
                        Color(0xFFA855F7),
                        Color(0xFF06B6D4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
