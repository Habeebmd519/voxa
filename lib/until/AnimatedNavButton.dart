import 'package:flutter/material.dart';
import 'package:voxa/screens/hello_screen.dart';
import 'package:voxa/screens/main_screen.dart';

class PremiumAnimatedButton extends StatefulWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool navigate; // whether to navigate after expansion

  const PremiumAnimatedButton({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    this.onTap,
    this.navigate = false,
  });

  @override
  State<PremiumAnimatedButton> createState() => _PremiumAnimatedButtonState();
}

class _PremiumAnimatedButtonState extends State<PremiumAnimatedButton>
    with SingleTickerProviderStateMixin {
  bool isPressed = false;

  void _handleTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.index == widget.selectedIndex;

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: isPressed ? 0.92 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack, // springy expansion
          width: isSelected ? 120 : 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(isSelected ? 0.45 : 0.0),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              // Fade + Zoom animation
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: isSelected
                ? GestureDetector(
                    onTap: () {
                      if (widget.navigate) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (!mounted) return;

                          final renderBox =
                              context.findRenderObject() as RenderBox?;
                          final buttonPosition =
                              renderBox?.localToGlobal(Offset.zero) ??
                              Offset.zero;
                          final buttonSize = renderBox?.size ?? Size.zero;

                          ///
                          ///
                          ///
                          ///
                          ///
                          // final BuildContext? buttonContext =
                          //     menuKey.currentContext;

                          // final RenderBox? renderBoxx =
                          //     buttonContext?.findRenderObject() as RenderBox?;

                          // final Offset buttonPositionn =
                          //     renderBoxx?.localToGlobal(Offset.zero) ??
                          //     Offset.zero;

                          // final Size buttonSizee =
                          //     renderBoxx?.size ?? Size.zero;

                          final targetRenderBox =
                              MainScreen.menuKey.currentContext
                                      ?.findRenderObject()
                                  as RenderBox?;
                          final endButtonPosition =
                              targetRenderBox?.localToGlobal(Offset.zero) ??
                              Offset.zero;
                          final endButtonSize =
                              targetRenderBox?.size ?? Size.zero;

                          debugPrint(endButtonSize.toString());
                          debugPrint(endButtonPosition.toString());

                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  ExpandingScreenFromButton(
                                    endButtonOffset: endButtonPosition,
                                    endButtonSize: endButtonSize,
                                    // buttonOffsetSecond: buttonPositionn,
                                    // buttonSizeSecond: buttonSizee,
                                    buttonOffset: buttonPosition,
                                    buttonSize: buttonSize,
                                  ),
                              transitionDuration: const Duration(
                                milliseconds: 700,
                              ),
                            ),
                          );
                        });
                      }
                    },
                    child: Text(
                      widget.label,
                      key: ValueKey("text${widget.index}"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Icon(
                    widget.icon,
                    key: ValueKey("icon${widget.index}"),
                    color: Colors.grey.shade700,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}
