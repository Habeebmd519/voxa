import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/auth/data/model/user_model.dart';
import 'package:synapse/feature/task/bottomSheet/cubit/sheet_cubit.dart';

import 'package:synapse/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:synapse/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';

class ChatProfileBackground extends StatefulWidget {
  final UserModel user;

  const ChatProfileBackground({super.key, required this.user});

  @override
  State<ChatProfileBackground> createState() => _ChatProfileBackgroundState();
}

class _ChatProfileBackgroundState extends State<ChatProfileBackground> {
  int? expandedIndex;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsheetmanageCubit, ChatsheetmanageState>(
      builder: (context, state) {
        return Container(
          // This ensures the gradient fills the available width
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB5D96A), Color(0xFF9FCC5A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              // 2. Added physics to ensure smooth scrolling in the sheet
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // const SizedBox(height: 30),

                  /// 🔥 PROFILE + RING
                  // _buildProfieAvatr(),
                  // const SizedBox(height: 16),

                  /// NAME
                  // Text(
                  //   widget.user.name,
                  //   style: const TextStyle(
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.w700,
                  //     color: Colors.black,
                  //   ),
                  // ),

                  // const SizedBox(height: 6),

                  // /// TAGLINE / DOMAIN
                  // Text(
                  //   widget.user.place ?? "Not Available",
                  //   style: TextStyle(
                  //     color: Colors.black.withOpacity(0.6),
                  //     fontSize: 13,
                  //   ),
                  // ),

                  // const SizedBox(height: 14),

                  // /// 🔥 SKILL CHIPS
                  // Wrap(
                  //   spacing: 10,
                  //   runSpacing: 8,
                  //   children: getIdentityChips(
                  //     widget.user,
                  //   ).map((text) => _chip(text)).toList(),
                  // ),
                  // const SizedBox(height: 20),

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
                  _sectionCard(
                    0,
                    Icons.star_border,
                    "Credibility",
                    widget.user,
                  ),
                  _sectionCard(1, Icons.work_outline, "Work", widget.user),
                  _sectionCard(2, Icons.flash_on, "Availability", widget.user),
                  _sectionCard(3, Icons.memory, "Skills", widget.user),
                  // Keep the bottom padding so content isn't hidden by the sheet
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // /// top profile avatar build
  // Widget _buildProfieAvatr() {
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       /// OUTER RING
  //       Container(
  //         width: 120,
  //         height: 120,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
  //         ),
  //       ),

  //       /// INNER RING (progress feel)
  //       Container(
  //         width: 100,
  //         height: 100,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           border: Border.all(color: Colors.white, width: 2),
  //         ),
  //       ),

  //       /// AVATAR
  //       CircleAvatar(
  //         radius: 42,
  //         backgroundColor: Colors.white,
  //         backgroundImage:
  //             widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty
  //             ? NetworkImage(widget.user.photoUrl!)
  //             : null,
  //         child: widget.user.photoUrl == null || widget.user.photoUrl!.isEmpty
  //             ? Text(
  //                 widget.user.name[0].toUpperCase(),
  //                 style: const TextStyle(
  //                   fontSize: 28,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               )
  //             : null,
  //       ),

  //       /// ONLINE DOT
  //       Positioned(
  //         bottom: 10,
  //         right: 10,
  //         child: Container(
  //           width: 14,
  //           height: 14,
  //           decoration: BoxDecoration(
  //             color: Colors.green,
  //             shape: BoxShape.circle,
  //             border: Border.all(color: Colors.white, width: 2),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  //getIdentityChips

  /// SECTION CARD
  Widget _sectionCard(int index, IconData icon, String title, UserModel user) {
    final isExpanded = expandedIndex == index;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)), // Slides up 30 pixels
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Rating
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 18),
            const SizedBox(width: 6),
            Text(
              "${user.rating.toStringAsFixed(2)} (${user.reviewCount} reviews)",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// Projects
        Row(
          children: [
            const Icon(Icons.folder, size: 18, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              "${user.completedProjects} Projects Completed",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            if (user.isEmailVerified) _badge(Icons.verified_rounded, "Email"),
            if (user.isPhoneVerified) _badge(Icons.phone_rounded, "Phone"),
            if (user.isPro) _proBadge(),
          ],
        ),
      ],
    );
  }

  Widget _badge(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: Colors.green.shade700),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

  // Top bar section
  Widget _topBarSction(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                context.read<SheetCubit>().openUsers();
                context.read<ChatsheetmanageCubit>().changeSheet(
                  Chatsheetmanage.half,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),

            const SizedBox(width: 10),

            /// 👤 AVATAR
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              backgroundImage:
                  user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            /// 🧠 USER INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME + VERIFIED
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (user.isEmailVerified)
                        Icon(Icons.verified, color: Colors.green, size: 16),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// DOMAIN + EXP
                  Text(
                    "${user.domain ?? "Developer"} • ${user.exp ?? "0"}+ yrs",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// RATING + STATUS
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        user.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "(${user.reviewCount})",
                        style: const TextStyle(fontSize: 11),
                      ),

                      const SizedBox(width: 10),

                      /// AVAILABILITY
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.isAvailable
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          user.isAvailable ? "Available" : "Busy",
                          style: TextStyle(
                            fontSize: 10,
                            color: user.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 👉 VIEW PROFILE BUTTON
            GestureDetector(
              onTap: () {
                // expand to full profile
                context.read<ChatsheetmanageCubit>().changeSheet(
                  Chatsheetmanage.zero,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("View", style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
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
