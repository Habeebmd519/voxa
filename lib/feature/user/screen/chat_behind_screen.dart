import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        child: SingleChildScrollView(
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
                spacing: 10,
                runSpacing: 8,
                children: getIdentityChips(
                  widget.user,
                ).map((text) => _chip(text)).toList(),
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
                    _StatItem(
                      value: "${widget.user.completedProjects}",
                      label: "Completed",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 SECTION CARDS (NOT FLAT ANYMORE)
              _sectionCard(0, Icons.star_border, "Credibility", widget.user),
              _sectionCard(1, Icons.work_outline, "Work", widget.user),
              _sectionCard(2, Icons.flash_on, "Availability", widget.user),
              _sectionCard(3, Icons.memory, "Skills", widget.user),
              SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  //getIdentityChips
  List<String> getIdentityChips(UserModel user) {
    List<String> chips = [];

    /// 1. DOMAIN (primary identity)
    if (user.domain != null && user.domain!.isNotEmpty) {
      chips.add(user.domain!);
    }

    /// 2. ROLE (only if different)
    if (user.role != null &&
        user.role!.isNotEmpty &&
        user.role != user.domain) {
      chips.add(user.role!);
    }

    /// 3. EXPERIENCE (formatted)
    if (user.exp != null && user.exp!.isNotEmpty) {
      chips.add("${user.exp}+ Years");
    }

    return chips;
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
                if (index == 1) _buildWork(user),
                if (index == 2) _buildAvailability(user),
                if (index == 3) _buildSkills(user),

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

  // skills
  Widget _buildSkills(UserModel user) {
    if (user.skills.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text("No skills added", style: TextStyle(color: Colors.black54)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: user.skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(skill, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }

  // Availbilities build
  Widget _buildAvailability(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// STATUS
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: user.isAvailable ? Colors.green : Colors.red,
            ),
            SizedBox(width: 6),
            Text(
              user.isAvailable ? "Available for work" : "Not available",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),

        SizedBox(height: 8),

        /// RESPONSE TIME
        Text("⚡ Responds: ${user.responseTime}"),

        SizedBox(height: 6),

        /// REMOTE
        Text(user.isRemote ? "🌍 Remote friendly" : "🏢 On-site only"),
      ],
    );
  }

  // work build
  Widget _buildWork(UserModel user) {
    if (user.projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "No projects added",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: user.projects.map((project) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              /// ICON
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.work, size: 18),
              ),

              const SizedBox(width: 10),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      project['desc'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              /// ARROW
              Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Credibility build

  Widget _buildCredibility(UserModel user) {
    //submition

    Future<void> submitReview({
      required String toUserId,
      required double rating,
      required String comment,
    }) async {
      final fromUserId = FirebaseAuth.instance.currentUser!.uid;

      // Save review
      await FirebaseFirestore.instance.collection('reviews').add({
        "fromUserId": fromUserId,
        "toUserId": toUserId,
        "rating": rating,
        "comment": comment,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Update rating avg
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(toUserId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(userRef);

        final data = snap.data()!;
        final oldRating = (data['rating'] ?? 0).toDouble();
        final count = (data['reviewCount'] ?? 0);

        final newCount = count + 1;
        final newRating = ((oldRating * count) + rating) / newCount;

        tx.update(userRef, {"rating": newRating, "reviewCount": newCount});
      });
    }

    void _showRatingDialog(BuildContext context, String toUserId) {
      double rating = 0;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Rate User"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (rating == 0) return;

                      await submitReview(
                        toUserId: toUserId,
                        rating: rating,
                        comment: "Good work",
                      );

                      Navigator.pop(context);
                    },
                    child: const Text("Submit"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    //check if did erly
    Future<bool> hasRated(String toUserId) async {
      final fromUserId = FirebaseAuth.instance.currentUser!.uid;

      final query = await FirebaseFirestore.instance
          .collection('reviews')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      return query.docs.isNotEmpty;
    }

    final rating = user.rating;
    final total = user.reviewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ⭐ TOP RATING SUMMARY
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),

            /// STARS
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.floor() ? Icons.star : Icons.star_border,
                  size: 18,
                  color: Colors.orange,
                );
              }),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          "$total reviews",
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),

        const SizedBox(height: 12),

        /// 📊 RATING BREAKDOWN (FAKE FOR NOW)
        _ratingBar(5, 0.7),
        _ratingBar(4, 0.5),
        _ratingBar(3, 0.2),
        _ratingBar(2, 0.05),
        _ratingBar(1, 0.02),

        const SizedBox(height: 12),

        /// 📁 PROJECTS
        Text("📁 ${user.completedProjects} Projects Completed"),

        const SizedBox(height: 10),

        /// 🏅 BADGES
        if (user.badges.isNotEmpty)
          Wrap(
            spacing: 6,
            children: user.badges.map((b) {
              return Chip(label: Text(b));
            }).toList(),
          ),

        const SizedBox(height: 10),

        /// 🔐 VERIFICATION
        Row(
          children: [
            if (user.isEmailVerified) _miniBadge(Icons.verified, "Email"),
            if (user.isPhoneVerified) _miniBadge(Icons.phone, "Phone"),
            if (user.isPro) _proBadge(),
          ],
        ),

        const SizedBox(height: 12),
        FutureBuilder<bool>(
          future: hasRated(user.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();

            if (snapshot.data == true) {
              return Text("You already rated");
            }

            return ElevatedButton(
              onPressed: () {
                _showRatingDialog(context, user.uid);
              },
              child: const Text("Rate User ⭐"),
            );
          },
        ),

        /// 💬 SAMPLE REVIEW CARD (UI ONLY)
        _reviewCard(),
      ],
    );
  }

  Widget _ratingBar(int star, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text("$star"),
          const Icon(Icons.star, size: 14, color: Colors.orange),
          const SizedBox(width: 6),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation(Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 12),
              const SizedBox(width: 6),
              const Text(
                "Client Name",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: List.generate(5, (i) {
              return const Icon(Icons.star, size: 14, color: Colors.orange);
            }),
          ),

          const SizedBox(height: 6),

          const Text(
            "Great developer, delivered on time 👌",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
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
