import 'package:flutter/material.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

class buildProfieAvatr extends StatelessWidget {
  UserModel user;
  buildProfieAvatr({required this.user});
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
              Container(
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

              /// INNER RING (progress feel)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),

              /// AVATAR
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                backgroundImage:
                    user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              /// ONLINE DOT
              Positioned(
                bottom: 10,
                right: 10,
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
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          /// TAGLINE / DOMAIN
          Text(
            user.place ?? "Not Available",
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
              user,
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
