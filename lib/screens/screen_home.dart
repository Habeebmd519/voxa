import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voxa/core/navigation/home_nav_controller.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:voxa/core/network/webRTC/voice_call/voice_call_cubit.dart';
import 'package:voxa/core/shimmer_loading/shimmer_loading.dart';
import 'package:voxa/core/widgets/bottom_content.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/profile/screens/profile_screen.dart';

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
import 'package:voxa/feature/user/screen/chat_behind_screen.dart';
import 'package:voxa/feature/user/screen/chat_screen.dart';
import 'package:voxa/feature/user/widget/chat_hedear.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HomeNavController.index,
      builder: (context, index, _) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, ProState) {
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
                          ? _buildProfileSection(ProState, context)
                          : SizedBox(),
                    );
                  },
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

    return Stack(
      children: [
        /// 🔥 BACKGROUND → PROFILE SHOWCASE
        ChatProfileBackground(user: state.user),

        /// 🔥 FOREGROUND → CHAT SHEET SYSTEM
        Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: getHeight(context, SheetState),
            ),

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

            if (SheetState.selectedSheet != Chatsheetmanage.zero) ...{
              ChatHeader(user: state.user),
              Expanded(
                child: AnimatedBottomContent(
                  contentKey: const ValueKey("chat_sheet"),
                  child: ChatScreen(receiverUser: state.user),
                ),
              ),
            },
          ],
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////
  ////.    _buildProfileSection     //////////////////////////
  ////////////////////////////////////////////////////

  // ── profile_screen.dart ────────────────────────────────────────────────────

  static const kGreen = Color(0xFFB5D96A);
  static const kPurple = Color.fromARGB(255, 79, 127, 47);
  static const kDarkGreen = Color(0xFF4a7c1f);

  Widget _buildProfileSection(ProfileState state, BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    // if (sate is) {}

    return Column(
      children: [
        // SizedBox(height: 30),
        _buildTopSection(state),
        const SizedBox(height: 16),
        Expanded(
          child: AnimatedBottomContent(
            contentKey: const ValueKey("profile_sheet"),
            child: ProfileScreen(state: state, uid: user.uid),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection(ProfileState state) {
    if (state is ProfileLoading) {
      return SizedBox();
    }

    if (state is ProfileError) {
      return Text(state.message);
    }

    if (state is ProfileLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _ProfileHeroCard(state: state),
      );
    }

    return const SizedBox();
  }

  //   Widget _buildBottomSection(ProfileState state, String uid) {
  //     if (state is ProfileLoading) {
  //       return const Center(child: ProfileShimmer()); // or mini shimmer
  //     }

  //     if (state is ProfileError) {
  //       return Center(child: Text(state.message));
  //     }

  //     if (state is ProfileLoaded) {
  //       return _ProfileSheetContent(state: state, uid: uid);
  //     }

  //     return const SizedBox();
  //   }
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

// // ── _ProfileHeroCard ───────────────────────────────────────────────────────

class _ProfileHeroCard extends StatelessWidget {
  final ProfileLoaded state;
  const _ProfileHeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 79, 127, 47),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        children: [
          // ── Avatar row ─────────────────────────────────────────
          Row(
            children: [
              // Avatar with camera button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color.fromARGB(255, 79, 127, 47),
                      backgroundImage:
                          (state.user.photoUrl != null &&
                              state.user.photoUrl!.isNotEmpty)
                          ? NetworkImage(
                              "${state.user.photoUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null,
                      child:
                          (state.user.photoUrl == null ||
                              state.user.photoUrl!.isEmpty)
                          ? Text(
                              state.user.name.isNotEmpty
                                  ? state.user.name[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Camera button — green with purple icon
                  Positioned(
                    bottom: 0,
                    right: -2,
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _popupBuilder(context),
                      ),

                      // context.read<ProfileCubit>().pickAndUploadImage(),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5D96A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromARGB(255, 79, 127, 47),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Color.fromARGB(255, 79, 127, 47),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // Name, location, email pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (state.user.place != null && state.user.place!.isNotEmpty)
                          ? "${state.user.place}"
                          : "Not Available",
                      // "NEW YORK", // replace with state.location
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (state.user.domain != null &&
                                state.user.domain!.isNotEmpty)
                            ? "${state.user.domain}"
                            : "Not Available",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          letterSpacing: .3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Divider ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white.withOpacity(0.2), height: 1),
          ),

          // ── Stats row ──────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                _StatItem(value: "221", label: "MESSAGES"),
                _VerticalDivider(),
                _StatItem(value: "48", label: "CONTACTS"),
                _VerticalDivider(),
                _StatItem(value: "5", label: "GROUPS"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _popupBuilder(BuildContext context) {
    final bool _hasPhoto =
        state.user.photoUrl != null && state.user.photoUrl!.isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Photo',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose an action',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Action items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // ADD
                _buildActionTile(
                  icon: Icons.add_photo_alternate_outlined,
                  label: 'Add Photo',
                  subtitle: 'Upload from your gallery',
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFF22C55E18),
                  tileBg: const Color(0xFFF0FDF4),
                  tileBorder: const Color(0xFFBBF7D0),
                  badgeLabel: 'Available',
                  badgeColor: const Color(0xFF22C55E),
                  badgeBg: const Color(0xFFDCFCE7),
                  enabled: !_hasPhoto,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ProfileCubit>().pickAndUploadImage();
                  },
                ),

                const SizedBox(height: 8),

                // CHANGE
                _buildActionTile(
                  icon: Icons.upload_outlined,
                  label: 'Change Photo',
                  subtitle: 'Replace with a new one',
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFF3B82F618),
                  tileBg: const Color(0xFFEFF6FF),
                  tileBorder: const Color(0xFFBFDBFE),
                  badgeLabel: 'Replace',
                  badgeColor: const Color(0xFF3B82F6),
                  badgeBg: const Color(0xFFDBEAFE),
                  enabled: _hasPhoto,
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await context
                        .read<ProfileCubit>()
                        .deleteMyProfileImage();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Profile photo deleted, Now choose one you want to.."
                              : "Failed to delete photo",
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                    context.read<ProfileCubit>().pickAndUploadImage();
                  },
                ),

                const SizedBox(height: 8),

                // DELETE
                _buildActionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete Photo',
                  subtitle: 'Remove profile picture',
                  iconColor: const Color(0xFFDC2626),
                  iconBg: const Color(0xFFEF444418),
                  tileBg: const Color(0xFFFFF5F5),
                  tileBorder: const Color(0xFFFECACA),
                  badgeLabel: 'Remove',
                  badgeColor: const Color(0xFFEF4444),
                  badgeBg: const Color(0xFFFEE2E2),
                  enabled: _hasPhoto,
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await context
                        .read<ProfileCubit>()
                        .deleteMyProfileImage();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Profile photo deleted,"
                              : "Failed to delete photo",
                        ),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color iconColor,
    required Color iconBg,
    required Color tileBg,
    required Color tileBorder,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeBg,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tileBorder, width: 1.5),
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),

              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white60,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: Colors.white.withOpacity(0.2));
  }
}

// ── _ProfileSheetContent (goes inside AnimatedBottomContent) ──────────────

// class _ProfileSheetContent extends StatelessWidget {
//   final ProfileLoaded state;
//   final String uid;
//   const _ProfileSheetContent({required this.state, required this.uid});

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//       children: [
//         // Drag handle
//         Center(
//           child: Container(
//             width: 36,
//             height: 4,
//             margin: const EdgeInsets.only(top: 10, bottom: 20),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ),

//         _ProfileField(label: "NAME", value: state.name),
//         _ProfileField(label: "EMAIL", value: state.email),
//         _ProfileField(label: "PASSWORD", value: "••••••••"),
//         _ProfileField(label: "USER ID", value: uid.substring(0, 8)),

//         const SizedBox(height: 24),

//         // Logout button
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: OutlinedButton(
//             onPressed: () {
//               // logout logic
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: const Color(0xFF7B2FBE),
//               side: const BorderSide(color: Color(0xFF7B2FBE), width: 1.5),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             child: const Text(
//               "Logout",
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF7B2FBE),
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }

// // // ── _ProfileField ──────────────────────────────────────────────────────────
// class _ProfileField extends StatelessWidget {
//   final String label;
//   final String value;

//   const _ProfileField({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50, // fixed height for uniform look
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEFF5F0), // softer grey
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           // LEFT LABEL
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF9E9E9E), // lighter grey
//               fontWeight: FontWeight.w500, // not bold
//               letterSpacing: 1.2, // spacing like design
//             ),
//           ),

//           const Spacer(),

//           // RIGHT VALUE
//           Expanded(
//             flex: 2,
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500, // medium, not bold
//                 color: Color(0xFF2C2C2C),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
