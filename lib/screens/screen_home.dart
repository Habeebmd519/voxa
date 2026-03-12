import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:voxa/core/navigation/home_nav_controller.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:voxa/core/widgets/bottom_content.dart';

import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';
import 'package:voxa/feature/task/profile_cubit/prifile_state.dart';
import 'package:voxa/feature/task/profile_cubit/profile_cubit.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/task/top_toggle_system/enum.dart';
import 'package:voxa/feature/task/user/bloc/UserCubit.dart';
import 'package:voxa/feature/task/user/bloc/UserState.dart';
import 'package:voxa/feature/task/user/screen/chat_screen.dart';

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
                      ? _buildAudioSection()
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

  Widget _buildAudioSection() {
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
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is UserEmpty) {
                  return const Center(child: Text("No users found"));
                }

                if (state is UserLoaded) {
                  final users = state.users;

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: const Color(0xFFAFDA6F),
                    ),
                    itemBuilder: (context, i) {
                      final user = users[i];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFAFDA6F),
                          radius: 22,
                          backgroundImage:
                              user.photoUrl != null && user.photoUrl!.isNotEmpty
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null || user.photoUrl!.isEmpty
                              ? Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user.email,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        onTap: () {
                          context.read<SheetCubit>().openChat(user);
                          // context.read<ChatCubit>().openChat(
                          //   user.uid,
                          // );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) =>
                          //         ChatScreen(receiverUser: user),
                          //   ),
                          // );
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
          print(state.message);
          return Center(child: Text(state.message));
        }

        if (state is ProfileLoaded) {
          return Column(
            children: [
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFAFDA6F),
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
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),

                  GestureDetector(
                    onTap: () {
                      context.read<ProfileCubit>().pickAndUploadImage();
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, size: 18),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: AnimatedBottomContent(
                  contentKey: const ValueKey("profile_sheet"),
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),

                      /// NAME
                      Text(
                        state.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// EMAIL
                      Text(
                        state.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// LOGOUT BUTTON (Optional)
                      ElevatedButton(
                        onPressed: () {
                          // logout logic
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
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
