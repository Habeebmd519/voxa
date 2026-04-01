import 'package:flutter/material.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

class ChatProfileBackground extends StatefulWidget {
  final UserModel user;

  const ChatProfileBackground({super.key, required this.user});

  @override
  State<ChatProfileBackground> createState() => _ChatProfileBackgroundState();
}

class _ChatProfileBackgroundState extends State<ChatProfileBackground> {
  int? expandedIndex;
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
              spacing: 8,
              children: [
                _chip(widget.user.domain ?? "Available for collaboration"),
                _chip(widget.user.role ?? ".."),
                if (widget.user.exp != null && widget.user.exp!.isNotEmpty)
                  _chip("${widget.user.exp} yr Experience"),
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
                    value: widget.user.projects.length.toString(),
                    label: "Projects",
                  ),
                  _Divider(),
                  _StatItem(
                    value: widget.user.rating.toStringAsFixed(1),
                    label: "Rating",
                  ),
                  _Divider(),
                  _StatItem(value: "${widget.user.exp}", label: "Exp"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 SECTION CARDS (NOT FLAT ANYMORE)
            _sectionCard(0, Icons.star_border, "Credibility", widget.user),
            _sectionCard(1, Icons.work_outline, "Work", widget.user),
            _sectionCard(2, Icons.flash_on, "Response", widget.user),
            _sectionCard(3, Icons.memory, "Skills", widget.user),
            // SizedBox(height: 20),r
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
  Widget _sectionCard(int index, IconData icon, String title, UserModel user) {
    final isExpanded = expandedIndex == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
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
                AnimatedRotation(
                  duration: Duration(milliseconds: 300),
                  turns: isExpanded ? 0.5 : 0.0,
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),

          /// 🔥 EXPAND CONTENT
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),
                if (index == 0) _buildCredibility(user),

                /// 🔥 TEMP CONTENT (MVP)
                // Text("Coming soon...", style: TextStyle(color: Colors.black54)),
              ],
            ),
            secondChild: SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildCredibility(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("⭐ ${user.rating} (${user.reviewCount} reviews)"),
        SizedBox(height: 6),
        Text("📁 ${user.completedProjects} Projects Completed"),
        SizedBox(height: 6),

        if (user.badges.isNotEmpty)
          Wrap(
            spacing: 6,
            children: user.badges.map((b) {
              return Chip(label: Text(b));
            }).toList(),
          ),

        SizedBox(height: 8),

        Row(
          children: [
            if (user.isEmailVerified) _miniBadge(Icons.verified, "Email"),
            if (user.isPhoneVerified) _miniBadge(Icons.phone, "Phone"),
            if (user.isPro) _proBadge(),
          ],
        ),
      ],
    );
  }

  Widget _miniBadge(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _proBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        "PRO",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
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
