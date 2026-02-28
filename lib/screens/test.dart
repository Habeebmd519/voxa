import 'dart:ui';
import 'package:flutter/material.dart';

/// iOS-inspired liquid glass bottom navigation bar with morphing animation
class LiquidBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const LiquidBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  State<LiquidBottomNavBar> createState() => _LiquidBottomNavBarState();
}

class _LiquidBottomNavBarState extends State<LiquidBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(LiquidBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7);
    final activeColor = widget.activeColor ?? Theme.of(context).primaryColor;
    final inactiveColor = widget.inactiveColor ?? Colors.grey;

    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Liquid morphing background
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: LiquidBubblePainter(
                        currentIndex: widget.currentIndex,
                        previousIndex: _previousIndex,
                        itemCount: widget.items.length,
                        animation: _animation.value,
                        color: activeColor.withOpacity(0.15),
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                // Nav items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    widget.items.length,
                    (index) => _buildNavItem(
                      widget.items[index],
                      index,
                      activeColor,
                      inactiveColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    NavItem item,
    int index,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withOpacity(0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: isActive ? activeColor : inactiveColor,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for liquid morphing effect
class LiquidBubblePainter extends CustomPainter {
  final int currentIndex;
  final int previousIndex;
  final int itemCount;
  final double animation;
  final Color color;

  LiquidBubblePainter({
    required this.currentIndex,
    required this.previousIndex,
    required this.itemCount,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final itemWidth = size.width / itemCount;

    // Calculate positions
    final previousX = itemWidth * previousIndex + itemWidth / 2;
    final currentX = itemWidth * currentIndex + itemWidth / 2;

    // Interpolate position
    final x = previousX + (currentX - previousX) * animation;

    // Create liquid blob effect
    final path = Path();

    // Dynamic radius based on animation
    final maxRadius = itemWidth * 0.6;
    final radius = maxRadius * (0.7 + 0.3 * _easeInOutElastic(animation));

    // Center circle
    path.addOval(
      Rect.fromCircle(center: Offset(x, size.height / 2), radius: radius),
    );

    // Add stretching effect during animation
    if (animation > 0 && animation < 1) {
      final stretchRadius = radius * 0.5;
      final midX = (previousX + currentX) / 2;

      // Create connecting blob
      path.addOval(
        Rect.fromCircle(
          center: Offset(midX, size.height / 2),
          radius: stretchRadius * (1 - (animation - 0.5).abs() * 2),
        ),
      );
    }

    canvas.drawPath(path, paint);
  }

  // Custom easing function for elastic effect
  double _easeInOutElastic(double t) {
    if (t == 0 || t == 1) return t;

    const p = 0.3;
    const s = p / 4;

    if (t < 0.5) {
      t = 2 * t;
      return -0.5 * (pow(2, 10 * (t - 1)) * sin((t - 1 - s) * (2 * pi) / p));
    } else {
      t = 2 * t - 1;
      return 0.5 * (pow(2, -10 * t) * sin((t - s) * (2 * pi) / p)) + 1;
    }
  }

  double pow(num x, num exponent) {
    return x.toDouble() * exponent.toDouble();
  }

  double sin(double radians) {
    return radians; // Simplified for example
  }

  double get pi => 3.14159265359;

  @override
  bool shouldRepaint(LiquidBubblePainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.previousIndex != previousIndex;
  }
}

/// Navigation item model
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// Example usage
class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home_rounded, label: 'Home'),
    NavItem(icon: Icons.explore_rounded, label: 'Explore'),
    NavItem(icon: Icons.favorite_rounded, label: 'Favorites'),
    NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  final List<Widget> _pages = const [
    Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    Center(child: Text('Explore', style: TextStyle(fontSize: 24))),
    Center(child: Text('Favorites', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF007AFF), // iOS blue
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      ),
      home: Scaffold(
        extendBody: true,
        body: _pages[_currentIndex],
        bottomNavigationBar: LiquidBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _navItems,
          backgroundColor: Colors.white.withOpacity(0.8),
          activeColor: const Color(0xFF007AFF),
          inactiveColor: Colors.grey.shade600,
        ),
      ),
    );
  }
}
