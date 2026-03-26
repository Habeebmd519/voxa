import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:voxa/core/navigation/home_nav_controller.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:voxa/core/network/webRTC/voice_call/voice_call_cubit.dart';
import 'package:voxa/core/widgets/bottom_content.dart';

import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';
import 'package:voxa/feature/task/profile_cubit/prifile_state.dart';
import 'package:voxa/feature/task/profile_cubit/profile_cubit.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/task/top_toggle_system/enum.dart';
import 'package:voxa/feature/user/bloc/UserCubit.dart';
import 'package:voxa/feature/user/bloc/UserState.dart';
import 'package:voxa/feature/user/screen/chat_screen.dart';
import 'package:voxa/feature/user/service/stream_datadase_service.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HomeNavController.index,
      builder: (context, index, _) {
        return BlocBuilder<ChatsheetmanageCubit, ChatsheetmanageState>(
          builder: (context, SheetState2) {
            return BlocBuilder<SheetCubit, SheetState>(
              builder: (context, state) {
                return Scaffold(
                  extendBody: true,
                  backgroundColor: Color.fromARGB(255, 175, 218, 111),
                  body: index == 0
                      ? (state is ShowUsers
                            ? _buildUserSection(state)
                            : _buildChatSection(
                                context,
                                state as ShowChat,
                                SheetState2,
                              ))
                      : index == 1
                      ? _buildAudioSection(context)
                      : index == 2
                      ? _buildVideoSction()
                      : index == 3
                      ? _buildProfileSection()
                      : SizedBox(),
                );
              },
            );
          },
        );
      },
    );
  }

  /////////////////////////////////////////////////////
  ////.    VIDEO SECTION     //////////////////////////
  ////////////////////////////////////////////////////

  Widget _buildVideoSction() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Expanded(
              //   child: ElevatedButton.icon(
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: const Size(double.infinity, 100),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //     ),
              //     onPressed: () {},
              //     label: Text("voice call"),
              //     icon: Icon(Icons.call),
              //   ),
              // ),
              // SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // TODO: walky-talky action
                  },
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        // outer shadow (separation from bg)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        // inner light effect
                        BoxShadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, -3),
                        ),
                      ],
                      color: const Color.fromARGB(255, 175, 218, 111),
                      image: const DecorationImage(
                        image: AssetImage("assets/videoMeetBg.png"),
                        fit: BoxFit.cover,
                        opacity: 0.25, // important: avoids overpowering text
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedVideo01,
                          size: 56,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Video Meet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBottomContent(
            contentKey: ValueKey("video_sheet"),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, i) {
                return const ListTile(title: Text("History"));
              },
            ),
          ),
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////
  ////.    ADIO SECTION     //////////////////////////
  ////////////////////////////////////////////////////

  Widget _buildAudioSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    String callId = FirebaseFirestore.instance
                        .collection('calls')
                        .doc()
                        .id;

                    context.read<CallCubit>().startCall(callId);
                  },

                  //                    () {
                  //                     // TODO: walky-talky action

                  //   String callId =
                  //       FirebaseFirestore.instance.collection('calls').doc().id;

                  //   context.read<CallCubit>().startCall(callId);
                  // }
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        // outer shadow (separation from bg)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        // inner light effect
                        BoxShadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, -3),
                        ),
                      ],
                      color: const Color.fromARGB(255, 175, 218, 111),
                      image: const DecorationImage(
                        image: AssetImage("assets/walkyTalkyBg.png"),
                        fit: BoxFit.cover,
                        opacity: 0.25, // important: avoids overpowering text
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedMic01,
                          size: 56,
                          color: Colors.white,
                        ),
                        // Icon(
                        //   Icons.mic_external_on,
                        //   size: 48,
                        //   color: Colors.white,
                        // ),
                        SizedBox(height: 8),
                        Text(
                          "Walky Talky",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBottomContent(
            contentKey: ValueKey("audio_sheet"),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, i) {
                return const ListTile(title: Text("History"));
              },
            ),
          ),
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////
  ////.    USER SECTION     //////////////////////////
  ////////////////////////////////////////////////////

  Widget _buildUserSection(ShowUsers state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<TopBarCubit, TopMode>(
            builder: (context, mode) {
              return Row(
                children: [
                  /// SEARCH AREA
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TopBarCubit>().showSearch();
                        debugPrint("$mode");
                        // setState(() {
                        //   mode = TopMode.search;
                        // });
                      },
                      child: AnimatedContainer(
                        curve: Curves.easeInOutQuart,
                        duration: Duration(milliseconds: 400),
                        height: 50,
                        width: mode == TopMode.add
                            ? 0
                            : mode == TopMode.search
                            ? MediaQuery.of(context).size.width * 1
                            : MediaQuery.of(context).size.width * 0.8,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: mode == TopMode.search
                              ? TextField(
                                  key: ValueKey("field"),
                                  decoration: InputDecoration(
                                    hintText: "Search user...",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                )
                              : Align(
                                  key: ValueKey("hint"),
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: mode == TopMode.add
                                        ? Text("from add")
                                        : Text("Search for anyone..."),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// ADD BUTTON
                  if (mode != TopMode.search && mode != TopMode.add)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutQuart,
                      height: 50,
                      width: switch (mode) {
                        TopMode.normal => 50, // visible

                        TopMode.add => 0, // hidden
                        TopMode.closingAdd => 0, // wait until field collapses
                        _ => 50,
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: mode == TopMode.normal
                            ? GestureDetector(
                                key: const ValueKey("addButton"),
                                onTap: () {
                                  context.read<TopBarCubit>().showAdd();
                                },
                                child: const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.add),
                                ),
                              )
                            : const SizedBox(key: ValueKey("empty")),
                      ),
                    ),
                  if (mode == TopMode.add) const Spacer(),

                  AnimatedContainer(
                    curve: Curves.easeInOutQuart,
                    duration: Duration(milliseconds: 400),
                    height: 50,
                    width: mode == TopMode.add
                        ? MediaQuery.of(context).size.width * 0.9
                        : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: AnimatedBottomContent(
            contentKey: ValueKey("user_sheet"),
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is UserError) {
                  print(state.message);
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.green),
                    ),
                  );
                }
                if (state is UserEmpty)
                  return const Center(child: Text("No users found"));

                if (state is UserLoaded) {
                  // final users = state.users;

                  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  final users = state.users
                      .where((u) => u.uid != currentUserId)
                      .toList();

                  ///
                  // final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  // final users = state.users
                  //     .where((u) => u.uid != currentUserId)
                  //     .toList();

                  ///
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final unreadMap =
                          data['unreadCount'] as Map<String, dynamic>? ?? {};

                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFAFDA6F)),
                        itemBuilder: (context, i) {
                          final user = users[i]; // This is already a UserModel
                          final currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;

                          final myUnread = unreadMap[user.uid] ?? 0;
                          // //////
                          // final currentUserData = users.firstWhere(
                          //   (u) => u.uid == currentUserId,
                          // );

                          // final myUnread =
                          //     currentUserData.unreadCount[user.uid] ?? 0;
                          // /////
                          // if (user == currentUserId) {}
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFAFDA6F),
                              radius: 22,
                              // FIX: Removed .user
                              backgroundImage:
                                  user.photoUrl != null &&
                                      user.photoUrl!.isNotEmpty
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child:
                                  user.photoUrl == null ||
                                      user.photoUrl!.isEmpty
                                  ? Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : '?', // FIX: Removed .user
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              user.name, // FIX: Removed .user
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              user.lastMessage != null &&
                                      user.lastMessage!.isNotEmpty
                                  ? user.lastMessage!
                                  : "Say hi 👋",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                // Make text bold if there are unread messages
                                fontWeight: myUnread > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: myUnread > 0
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            onTap: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserId)
                                  .update({'unreadCount.${user.uid}': 0});
                              // FIX: Pass 'user' directly, removed .user
                              context.read<SheetCubit>().openChat(user);
                            },
                            trailing:
                                (myUnread >
                                    0) // Remove the lastSenderId check - show unread regardless of who sent last
                                ? CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.green,
                                    child: Text(
                                      myUnread.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////
  ////.    CHAT SECTION     //////////////////////////
  ////////////////////////////////////////////////////

  Widget _buildChatSection(
    BuildContext context,
    ShowChat state,
    ChatsheetmanageState SheetState,
  ) {
    double getHeight(BuildContext context, ChatsheetmanageState state) {
      switch (state.selectedSheet) {
        case Chatsheetmanage.full:
          return 0;
        case Chatsheetmanage.half:
          return 200;
        case Chatsheetmanage.zero:
          return MediaQuery.of(context).size.height * 0.7;
      }
    }

    return Column(
      children: [
        AnimatedContainer(
          curve: Curves.easeInCubic,
          duration: Duration(milliseconds: 300),
          width: double.infinity,
          height: getHeight(context, SheetState),
          color: Colors.transparent,
        ),

        // Center(
        //   child: Text("v", style: TextStyle(fontWeight: FontWeight.bold)),
        // ),
        if (SheetState.selectedSheet == Chatsheetmanage.zero)
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () {
                  context.read<ChatsheetmanageCubit>().changeSheet(
                    Chatsheetmanage.full,
                  );
                },
                child: const BouncingArrow(),
              ),
            ),
          ),
        if (SheetState.selectedSheet != Chatsheetmanage.zero)
          Expanded(
            child: AnimatedBottomContent(
              contentKey: const ValueKey("chat_sheet"),
              child: ChatScreen(receiverUser: state.user),
            ),
          ),
      ],
    );
  }

  /////////////////////////////////////////////////////
  ////.    CHAT SECTION     //////////////////////////
  ////////////////////////////////////////////////////

  Widget _buildProfileSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfileError) {
          return Center(child: Text(state.message));
        }
        if (state is ProfileLoaded) {
          return Column(
            children: [
              /// ── Purple header with blurred background + avatar ──
              _ProfileHeader(state: state),

              /// ── Scrollable info fields below ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  children: [
                    const SizedBox(height: 12),
                    _ProfileInfoTile(label: "Name", value: state.name),
                    _ProfileInfoTile(label: "Email", value: state.email),
                    _ProfileInfoTile(label: "Password", value: "••••••••"),
                    _ProfileInfoTile(
                      label: "User ID",
                      value: user.uid.substring(0, 8),
                    ),
                    // Add more fields as needed
                    const SizedBox(height: 24),
                    _LogoutButton(),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  // Widget _buildProfileSection() {
  //   final user = FirebaseAuth.instance.currentUser;

  //   if (user == null) {
  //     return const Center(child: Text("Not logged in"));
  //   }
  //   return BlocBuilder<ProfileCubit, ProfileState>(
  //     builder: (context, state) {
  //       if (state is ProfileLoading) {
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       if (state is ProfileError) {
  //         print(state.message);
  //         return Center(child: Text(state.message));
  //       }

  //       if (state is ProfileLoaded) {
  //         return Column(
  //           children: [
  //             const SizedBox(height: 30),
  //             Stack(
  //               alignment: Alignment.bottomRight,
  //               children: [
  //                 CircleAvatar(
  //                   radius: 60,
  //                   backgroundColor: const Color(0xFFAFDA6F),
  //                   backgroundImage:
  //                       (state.photoUrl != null && state.photoUrl!.isNotEmpty)
  //                       ? NetworkImage(
  //                           "${state.photoUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
  //                         )
  //                       : null,
  //                   child: (state.photoUrl == null || state.photoUrl!.isEmpty)
  //                       ? Text(
  //                           state.name.isNotEmpty
  //                               ? state.name[0].toUpperCase()
  //                               : "?",
  //                           style: const TextStyle(
  //                             fontSize: 40,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black,
  //                           ),
  //                         )
  //                       : null,
  //                 ),

  //                 GestureDetector(
  //                   onTap: () {
  //                     context.read<ProfileCubit>().pickAndUploadImage();
  //                   },
  //                   child: const CircleAvatar(
  //                     radius: 18,
  //                     backgroundColor: Colors.white,
  //                     child: Icon(Icons.camera_alt, size: 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Expanded(
  //               child: AnimatedBottomContent(
  //                 contentKey: const ValueKey("profile_sheet"),
  //                 child: ListView(
  //                   children: [
  //                     const SizedBox(height: 20),

  //                     /// NAME
  //                     Text(
  //                       state.name,
  //                       style: const TextStyle(
  //                         fontSize: 22,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),

  //                     const SizedBox(height: 6),

  //                     /// EMAIL
  //                     Text(
  //                       state.email,
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         color: Colors.grey.shade600,
  //                       ),
  //                     ),

  //                     const SizedBox(height: 30),

  //                     /// LOGOUT BUTTON (Optional)
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         // logout logic
  //                       },
  //                       child: const Text("Logout"),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       }
  //       return const SizedBox();
  //     },
  //   );
  // }
}

class BouncingArrow extends StatefulWidget {
  const BouncingArrow({super.key});

  @override
  State<BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<BouncingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: CircleAvatar(
        backgroundColor: Color.fromARGB(255, 79, 127, 47),
        child: const Icon(
          Icons.keyboard_arrow_up,
          size: 40,
          color: Color.fromARGB(255, 175, 218, 111),
        ),
      ),
    );
  }
}

/// ── Header widget ──────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final ProfileLoaded state;
  const _ProfileHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2FBE);

    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// Purple gradient background
          Container(
            height: 170,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7B2FBE), Color(0xFF9B4DD4)],
              ),
            ),

            /// Optional: blurred profile image as bg overlay
            child: (state.photoUrl != null && state.photoUrl!.isNotEmpty)
                ? Opacity(
                    opacity: 0.25,
                    child: Image.network(
                      state.photoUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : null,
          ),

          /// Name + location centered below avatar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(height: 52), // space for avatar
                Text(
                  state.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "NEW YORK", // replace with state.location if available
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          /// Avatar circle — centered, overlapping the header
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: purple,
                      backgroundImage:
                          (state.photoUrl != null && state.photoUrl!.isNotEmpty)
                          ? NetworkImage(
                              "${state.photoUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null,
                      child: (state.photoUrl == null || state.photoUrl!.isEmpty)
                          ? Text(
                              state.name.isNotEmpty
                                  ? state.name[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),

                  /// Camera button bottom-right of avatar
                  Positioned(
                    bottom: 0,
                    right: -4,
                    child: GestureDetector(
                      onTap: () =>
                          context.read<ProfileCubit>().pickAndUploadImage(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Color(0xFF7B2FBE),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Single info row ────────────────────────────────────────────
class _ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileInfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7B2FBE),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

/// ── Logout button ──────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // your logout logic
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7B2FBE),
          side: const BorderSide(color: Color(0xFF7B2FBE)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}
