import 'package:flutter/material.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

class buildProfieAvatr extends StatefulWidget {
  UserModel user;
  buildProfieAvatr({required this.user});

  @override
  State<buildProfieAvatr> createState() => _buildProfieAvatrState();
}

class _buildProfieAvatrState extends State<buildProfieAvatr>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Keep it spinning slowly
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              /// OUTER RING
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.1),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                    ),
                  );
                },
              ),

              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  // Optional: Use a CustomPainter here for a dashed line effect
                ),
              ),

              /// AVATAR
              Hero(
                tag: 'profile_${widget.user.uid}',
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      widget.user.photoUrl != null &&
                          widget.user.photoUrl!.isNotEmpty
                      ? NetworkImage(widget.user.photoUrl!)
                      : null,
                  child:
                      widget.user.photoUrl == null ||
                          widget.user.photoUrl!.isEmpty
                      ? Text(
                          widget.user.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),

              /// ONLINE DOT
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            widget.user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          /// TAGLINE / DOMAIN
          Text(
            widget.user.place ?? "Not Available",
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          /// 🔥 SKILL CHIPS
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: getIdentityChips(
              widget.user,
            ).map((text) => _chip(text)).toList(),
          ),
        ],
      ),
    );
  }
}

/// CHIP
Widget _chip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
}

List<String> getIdentityChips(UserModel user) {
  List<String> chips = [];

  /// 1. DOMAIN (primary identity)
  if (user.domain != null && user.domain!.isNotEmpty) {
    chips.add(user.domain!);
  }

  /// 2. ROLE (only if different)
  if (user.role != null && user.role!.isNotEmpty && user.role != user.domain) {
    chips.add(user.role!);
  }

  /// 3. EXPERIENCE (formatted)
  if (user.exp != null && user.exp!.isNotEmpty) {
    chips.add("${user.exp}+ Years");
  }

  return chips;
}
