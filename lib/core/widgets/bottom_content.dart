// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedBottomContent extends StatelessWidget {
  final Widget child;
  final Key contentKey;
  final Color bgColor;

  const AnimatedBottomContent({
    super.key,
    required this.child,
    required this.contentKey,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      child: Container(
        key: contentKey,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: child,
      ),
    );
  }
}
