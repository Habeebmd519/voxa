import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';

class ChatHeader extends StatelessWidget {
  final UserModel user;
  final Stream<DocumentSnapshot>? userStream;

  const ChatHeader({super.key, required this.user, this.userStream});

  @override
  Widget build(BuildContext context) {
    @override
    Widget build(BuildContext context) {
      if (userStream == null) {
        return _buildUI(context, user);
      }

      return StreamBuilder<DocumentSnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          UserModel liveUser = user;

          if (snapshot.hasData && snapshot.data?.data() != null) {
            try {
              liveUser = UserModel.fromMap(
                snapshot.data!.data() as Map<String, dynamic>,
              );
            } catch (_) {}
          }

          return _buildUI(context, liveUser);
        },
      );
    }

    return SafeArea(
      bottom: false,
      // top: false,
      child: Padding(
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
              Hero(
                tag: 'profile_${user.uid}',
                child: CircleAvatar(
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
                              color: user.isAvailable
                                  ? Colors.green
                                  : Colors.red,
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
      ),
    );
  }

  Widget _buildUI(BuildContext context, UserModel user) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              /// BACK BUTTON
              GestureDetector(
                onTap: () {
                  context.read<SheetCubit>().openUsers();
                  context.read<ChatsheetmanageCubit>().changeSheet(
                    Chatsheetmanage.half,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, size: 18),
                ),
              ),

              const SizedBox(width: 10),

              /// AVATAR
              Hero(
                tag: 'profile_${user.uid}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              /// USER INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (user.isEmailVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${user.domain ?? "Developer"} • ${user.exp ?? "0"}+ yrs",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(user.rating.toStringAsFixed(1)),
                        const SizedBox(width: 6),
                        Text("(${user.reviewCount})"),

                        const SizedBox(width: 10),

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
                              color: user.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// VIEW BUTTON
              GestureDetector(
                onTap: () {
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
      ),
    );
  }
}
