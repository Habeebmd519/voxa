import 'package:flutter/material.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

class ChatProfileBackground extends StatelessWidget {
  final UserModel user;

  const ChatProfileBackground({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB5D96A), Color(0xFF9FCC5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            /// 🔥 PROFILE + RING
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

            const SizedBox(height: 16),

            /// NAME
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
              spacing: 8,
              children: [
                _chip(user.domain ?? "Available for collaboration"),
                _chip(user.role ?? ".."),
                if (user.exp != null && user.exp!.isNotEmpty)
                  _chip("${user.exp} yr Experience"),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 STATS CARD (LIKE YOUR REFERENCE)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    value: user.projects.length.toString(),
                    label: "Projects",
                  ),
                  _Divider(),
                  _StatItem(value: "4.9", label: "Rating"),
                  _Divider(),
                  _StatItem(value: "${user.exp}", label: "Exp"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 SECTION CARDS (NOT FLAT ANYMORE)
            _sectionCard(Icons.star_border, "Credibility"),
            _sectionCard(Icons.work_outline, "Work"),
            _sectionCard(Icons.flash_on, "Response"),
            _sectionCard(Icons.memory, "Skills"),
          ],
        ),
      ),
    );
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

  /// SECTION CARD
  Widget _sectionCard(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

/// STAT ITEM
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// DIVIDER
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.black.withOpacity(0.1),
    );
  }
}
