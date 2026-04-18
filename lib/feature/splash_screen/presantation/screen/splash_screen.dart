import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:voxa/screens/main_screen.dart';
import 'package:voxa/feature/auth/presentation/screens/screen_login.dart';

// ─── App Color Palette (Green Theme) ─────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF1A2E0F); // deep forest bg
  static const backgroundCard = Color(0xFF1F3A10); // loader track
  static const coreGradStart = Color(0xFF3A7D14); // dark green
  static const coreGradMid = Color(0xFF5CB82A); // primary green
  static const coreGradEnd = Color(0xFF7ED84A); // bright green
  static const orb1 = Color(0xFF7ED84A);
  static const orb2 = Color(0xFFA8E87A);
  static const orb3 = Color(0xFF5CB82A);
  static const orb4 = Color(0xFFC8F080);
  static const ring1 = Color(0xFF5A9E28); // ring border
  static const ring2 = Color(0xFF3D7A18);
  static const glowCenter = Color(0xFF4A7C22);
  static const nameStart = Color(0xFFA8E87A);
  static const nameEnd = Color(0xFFD4F5A0);
  static const divider = Color(0xFF5CB82A);
  static const tagline = Color(0xFF5A8A3A);
  static const loadText = Color(0xFF3D5C28);
  static const star = Color(0xFFA8D57A);
  static const leaf = Color(0xFF5CB82A);
  static const dotActive = Color(0xFF5CB82A);
  static const dotInactive = Color(0xFF2D5010);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SynapseApp());
}

class SynapseApp extends StatelessWidget {
  const SynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SynapseSplashScreen(),
    );
  }
}

// ─── Online Presence Service ──────────────────────────────────────────────────

/// Manages the user's isOnline flag in Firebase Realtime Database.
/// Path: users/{uid}/isOnline
/// Also uses .onDisconnect() so Firebase sets isOnline=false automatically
/// when the client loses connection (app killed, network lost, etc.).
class OnlinePresenceService {
  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Call on login / app open: sets isOnline=true + registers onDisconnect hook.
  static Future<void> goOnline(String uid) async {
    final ref = _db.ref('users/$uid');
    // onDisconnect fires server-side even if the app is force-killed
    await ref.child('isOnline').onDisconnect().set(false);
    await ref.update({'isOnline': true, 'lastSeen': ServerValue.timestamp});
  }

  /// Call explicitly when the user logs out or the app is gracefully closed.
  static Future<void> goOffline(String uid) async {
    final ref = _db.ref('users/$uid');
    await ref.update({'isOnline': false, 'lastSeen': ServerValue.timestamp});
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────────

class SynapseSplashScreen extends StatefulWidget {
  const SynapseSplashScreen({super.key});

  @override
  State<SynapseSplashScreen> createState() => _SynapseSplashScreenState();
}

class _SynapseSplashScreenState extends State<SynapseSplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ── Auth state ──────────────────────────────────────────────────────────────
  String? _loggedInUid; // non-null means user is logged in
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

    // Register lifecycle observer so we can react to app pause/resume
    WidgetsBinding.instance.addObserver(this);

    // Check login state and handle Firebase presence
    _checkAuthAndNavigate();
  }

  // ── Auth + presence logic ───────────────────────────────────────────────────
  Future<void> _checkAuthAndNavigate() async {
    print("🚀 Splash started");

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    print("👤 UID: $uid");

    final isLoggedIn = uid != null && uid.isNotEmpty;

    if (isLoggedIn) {
      _loggedInUid = uid;

      // 🔥 DON'T await
      OnlinePresenceService.goOnline(uid);
    }

    await Future.delayed(const Duration(seconds: 2));

    print("➡️ Navigating...");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const MainScreen() : AnimatedLoginScreen(),
      ),
    );
  }
  // ── App lifecycle: set offline when app is backgrounded/closed ──────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_loggedInUid == null) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App going to background or being killed — mark offline
        OnlinePresenceService.goOffline(_loggedInUid!);
        break;
      case AppLifecycleState.resumed:
        // App came back to foreground — mark online again
        OnlinePresenceService.goOnline(_loggedInUid!);
        break;
      case AppLifecycleState.inactive:
        // Transitional state (e.g. phone call overlay) — no action needed
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow blobs
          _BackgroundGlows(glowAnim: _glowAnim),

          // Decorative leaves
          const _LeafDecorations(),

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
                          AppColors.nameStart,
                          Colors.white,
                          AppColors.nameEnd,
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
                      width: 52,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.divider,
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
                          fontSize: 11,
                          letterSpacing: 3.5,
                          color: AppColors.tagline,
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
                        fontSize: 11,
                        color: AppColors.loadText,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Pulsing dots
                    _PulsingDots(),
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
            top: -80,
            left: -80,
            child: _GlowBlob(
              size: 320,
              color: AppColors.glowCenter.withOpacity(0.18 * glowAnim.value),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: _GlowBlob(
              size: 280,
              color: const Color(0xFF2D5A10).withOpacity(0.18 * glowAnim.value),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: _GlowBlob(
                size: 220,
                color: const Color(
                  0xFF6ABF28,
                ).withOpacity(0.12 * glowAnim.value),
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
          color: AppColors.star,
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
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.ring1.withOpacity(0.35),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Ring 2 (reverse)
          RotationTransition(
            turns: Tween<double>(begin: 1, end: 0).animate(ring2),
            child: Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.ring2.withOpacity(0.28),
                  width: 1,
                ),
              ),
            ),
          ),

          // Core icon
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.coreGradStart,
                  AppColors.coreGradMid,
                  AppColors.coreGradEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coreGradMid.withOpacity(0.4),
                  blurRadius: 36,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.coreGradStart.withOpacity(0.15),
                  blurRadius: 70,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 40,
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
            color: AppColors.orb1,
            size: 14,
            baseOffset: const Offset(0, -60),
          ),
          _OrbWidget(
            controller: orb2,
            color: AppColors.orb2,
            size: 10,
            baseOffset: const Offset(58, 0),
          ),
          _OrbWidget(
            controller: orb3,
            color: AppColors.orb3,
            size: 12,
            baseOffset: const Offset(-50, 34),
          ),
          _OrbWidget(
            controller: orb4,
            color: AppColors.orb4,
            size: 8,
            baseOffset: const Offset(38, 42),
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

// ─── Leaf Decorations ─────────────────────────────────────────────────────────

class _LeafDecorations extends StatefulWidget {
  const _LeafDecorations();
  @override
  State<_LeafDecorations> createState() => _LeafDecorationsState();
}

class _LeafDecorationsState extends State<_LeafDecorations>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _sway;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _sway = Tween<double>(
      begin: -0.14,
      end: 0.14,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _sway,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: sz.height * 0.08,
            right: sz.width * 0.06,
            child: Transform.rotate(
              angle: _sway.value,
              alignment: Alignment.bottomCenter,
              child: Opacity(opacity: 0.09, child: _LeafShape(size: 80)),
            ),
          ),
          Positioned(
            bottom: sz.height * 0.12,
            left: sz.width * 0.05,
            child: Transform.rotate(
              angle: -_sway.value * 1.3,
              alignment: Alignment.bottomCenter,
              child: Opacity(opacity: 0.07, child: _LeafShape(size: 56)),
            ),
          ),
          Positioned(
            top: sz.height * 0.52,
            right: sz.width * 0.03,
            child: Transform.rotate(
              angle: 0.5 + _sway.value,
              alignment: Alignment.bottomCenter,
              child: Opacity(opacity: 0.06, child: _LeafShape(size: 44)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafShape extends StatelessWidget {
  final double size;
  const _LeafShape({required this.size});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size * 1.25), painter: _LeafPainter());
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = AppColors.leaf
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final path = Path()
      ..moveTo(cx, size.height)
      ..cubicTo(0, size.height * 0.65, 0, size.height * 0.15, cx, 0)
      ..cubicTo(
        size.width,
        size.height * 0.15,
        size.width,
        size.height * 0.65,
        cx,
        size.height,
      );
    canvas.drawPath(path, fill);
    canvas.drawLine(
      Offset(cx, size.height),
      Offset(cx, 0),
      Paint()
        ..color = AppColors.coreGradStart
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Pulsing Dots ─────────────────────────────────────────────────────────────

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final phase = (_ctrl.value - i * 0.33).clamp(0.0, 1.0);
            final opacity = (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(
              0.2,
              1.0,
            );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.dotActive.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
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
            Container(color: AppColors.backgroundCard),
            AnimatedBuilder(
              animation: loadAnim,
              builder: (_, __) => FractionallySizedBox(
                widthFactor: loadAnim.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.coreGradStart,
                        AppColors.coreGradMid,
                        AppColors.orb2,
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

// ─── Placeholder screens (replace with your real screens) ────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home Screen')));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Login Screen')));
}

// ─── How to save UID on login (call this from your login flow) ────────────────
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// Future<void> onLoginSuccess(String uid) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('uid', uid);
//   await OnlinePresenceService.goOnline(uid);
// }
//
// Future<void> onLogout(String uid) async {
//   await OnlinePresenceService.goOffline(uid);
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('uid');
// }
