import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/number_symbols_data.dart';

import 'package:voxa/core/navigation/home_nav_controller.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:voxa/core/network/webRTC/voice_call/voice_call_cubit.dart';
import 'package:voxa/core/shimmer_loading/shimmer_loading.dart';
import 'package:voxa/core/widgets/bottom_content.dart';
import 'package:voxa/feature/Drop/pressantation/bloc/filterCubit.dart';
import 'package:voxa/feature/Drop/pressantation/bloc/friendCubit/freindCubit.dart';
import 'package:voxa/feature/Drop/pressantation/bloc/friendCubit/freindState.dart';
import 'package:voxa/feature/Drop/pressantation/bloc/timeLineCubit.dart';
import 'package:voxa/feature/Drop/pressantation/bloc/timeLineState.dart';
import 'package:voxa/feature/Drop/pressantation/modes/dropModel.dart';
import 'package:voxa/feature/Drop/servises/services.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/profile/screens/profile_screen.dart';
import 'package:voxa/feature/search_from_firebase/bloc/searchCubit.dart';
import 'package:voxa/feature/search_from_firebase/bloc/searchState.dart';

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
import 'package:voxa/feature/user/bloc/current_user_cubit.dart';
import 'package:voxa/feature/user/screen/chatHeaderFlow.dart';
import 'package:voxa/feature/user/screen/chat_flow_screen.dart';

import 'package:voxa/feature/user/screen/chat_screen.dart';
import 'package:voxa/feature/user/utils/behind_screen_flow.dart/behind_sccreen_flow.dart';
import 'package:voxa/feature/user/widget/behind_top_flow.dart';
import 'package:voxa/feature/user/widget/behind_top_swction.dart';
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
                          ? _buildSearchSection(context, SheetState2)
                          : index == 2
                          ? BlocBuilder<TimelineCubit, TimelineState>(
                              builder: (context, timelineState) {
                                if (timelineState is TimelineLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (timelineState is TimelineLoaded) {
                                  return _buildTimeLineSection(
                                    context,
                                    timelineState.drops,
                                  );
                                }

                                return const Center(
                                  child: Text("Something went wrong"),
                                );
                              },
                            )
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
  Widget _buildTimeLineSection(BuildContext context, List<DropModel> drops) {
    final user = FirebaseAuth.instance.currentUser;
    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        final cubit = context.watch<TimelineCubit>();
        // final user = FirebaseAuth.instance.currentUser;

        if (state is! TimelineLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            /// MAIN CONTENT
            Column(
              children: [
                _buildFilterChips(context),

                Expanded(
                  child: AnimatedBottomContent(
                    bgColor: Colors.transparent,
                    contentKey: ValueKey(cubit.currentFilter),
                    child: ListView.builder(
                      key: ValueKey(cubit.currentFilter),
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: state.drops.length,
                      itemBuilder: (context, index) {
                        final currentUser = context
                            .watch<CurrentUserCubit>()
                            .state;

                        if (currentUser == null) {
                          return const SizedBox();
                        }
                        return _DropCard(
                          user: currentUser,
                          drop: state.drops[index],
                          currentUserId: user?.uid ?? '',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            /// ✅ SHOW FAB ONLY FOR "MY DROPS"
            if (cubit.currentFilter == DropFilter.mine)
              Positioned(
                bottom:
                    MediaQuery.of(context).padding.bottom + 10, // 🔥 key fix
                right: 20,
                child: _buildModernFAB(context),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    void _openCreateDrop(BuildContext context) {
      final controller = TextEditingController();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// HANDLE
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  /// TITLE
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Create Drop",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// INPUT
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;

                        final currentUser = context
                            .read<CurrentUserCubit>()
                            .state;

                        await FirebaseFirestore.instance
                            .collection('posts')
                            .add({
                              'userId': currentUser!.uid, // ✅ IMPORTANT
                              'userName': currentUser?.name ?? "User",
                              'userEmail': currentUser?.email ?? '',
                              'userAvatar': currentUser?.photoUrl ?? "",
                              'text': text,
                              'createdAt': FieldValue.serverTimestamp(),
                              'likeCount': 0,
                            });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Drop"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => _openCreateDrop(context),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  //// filter chips build
  Widget _buildFilterChips(BuildContext context) {
    final filters = DropFilter.values;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final cubit = context.watch<TimelineCubit>();
            final isSelected = cubit.currentFilter == filter;

            return Padding(
              // decoration: BoxDecoration(
              //   // borderRadius: BorderRadius.circular(30),
              //   color: Color.fromARGB(255, 110, 160, 80),
              // ),
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                // backgroundColor: Color.fromARGB(255, 110, 160, 80),
                // selectedColor: Color.fromARGB(255, 79, 127, 47),
                label: Text(
                  filter.label,
                  style: TextStyle(color: Colors.white),
                ),
                side: BorderSide.none, // ← Main fix
                // Optional: Make it look cleaner without border
                shape: const StadiumBorder(),
                color: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Color.fromARGB(
                      255,
                      110,
                      160,
                      80,
                    ); // removes hover color
                  }
                  if (states.contains(WidgetState.selected)) {
                    return Color.fromARGB(255, 79, 127, 47);
                  }
                  return Color.fromARGB(255, 110, 160, 80);
                }),
                selected: isSelected,
                onSelected: (_) {
                  final myId = FirebaseAuth.instance.currentUser!.uid;
                  final friendIds =
                      context.read<CurrentUserCubit>().state?.friendIds ?? [];

                  context.read<TimelineCubit>().applyFilter(
                    filter,
                    myId,
                    friendIds,
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<DropModel> _filteredDrops(
    List<DropModel> drops,
    String selectedFilter,
    String myId,
    List<String> friendIds,
  ) {
    switch (selectedFilter) {
      case "Friends Drops":
        return drops.where((d) => friendIds.contains(d.userId)).toList();

      case "My Drops":
        return drops.where((d) => d.userId == myId).toList();

      default:
        return drops;
    }
  }

  // "'''
  //
  //

  //
  //
  //
  // ''''"

  /////////////////////////////////////////////////////
  ////.    ADIO SECTION     //////////////////////////
  ////////////////////////////////////////////////////
  Widget _buildSearchSection(
    BuildContext context,

    ChatsheetmanageState SheetState,
  ) {
    final controller = TextEditingController(text: '');
    // final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      children: [
        /// 🔍 SEARCH BARX$
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: controller,
              key: const ValueKey("search_global"),
              onChanged: (value) {
                context.read<SearchCubit>().onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: "Search people...",
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    controller.clear();
                    context.read<SearchCubit>().clear();
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// 📂 CONTENT
        Expanded(
          child: AnimatedBottomContent(
            bgColor: Colors.white,
            contentKey: const ValueKey("search_sheet"),
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                /// 🟢 INITIAL
                if (state is SearchInitial) {
                  return const Center(
                    child: Text("Search people to start chatting"),
                  );
                }

                /// 🔄 LOADING
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// ❌ EMPTY
                if (state is SearchEmpty) {
                  return const Center(child: Text("No users found"));
                }

                /// ✅ SUCCESS
                if (state is SearchSuccess) {
                  final users = state.users;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: users.length,
                    itemBuilder: (context, i) {
                      final user = users[i];
                      final myId = FirebaseAuth.instance.currentUser!.uid;

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          backgroundColor: Colors.grey,
                          child: user.photoUrl == null
                              ? Text(user.name[0].toUpperCase())
                              : null,
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user.domain ?? user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: user.isPro
                            ? const Icon(Icons.star, color: Colors.amber)
                            : const Icon(Icons.north_west),

                        onTap: () {
                          // 1. Switch to chat tab
                          HomeNavController.index.value = 0;

                          // 2. Open chat
                          context.read<SheetCubit>().openChat(user);
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
                  if (mode == TopMode.add) Spacer(),
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
            bgColor: Colors.white,
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

                  final currentUser = context.watch<CurrentUserCubit>().state;

                  if (currentUser == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final currentUserId = currentUser.uid;

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
                              final user = users[i]; // UserHiveModel
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserId)
                                  .update({'unreadCount.${user.uid}': 0});
                              // FIX: Pass 'user' directly, removed .user

                              context.read<SheetCubit>().openChat(
                                user.toUserModel(), // ✅ convert here
                              );
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
    // return StreamBuilder<DocumentSnapshot>(
    //   stream: FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(state.user.uid)
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     UserModel fullUser = state.user;
    //     if (snapshot.hasData && snapshot.data?.data() != null) {
    //       try {
    //         fullUser = UserModel.fromMap(
    //           snapshot.data!.data() as Map<String, dynamic>,
    //         );
    //       } catch (e) {
    //         debugPrint("Error parsing full user: $e");
    //       }
    //     }

    return Column(
      children: [
        if (SheetState.selectedSheet == Chatsheetmanage.zero) ...{
          BehindTopFlow(user: state.user),
          Expanded(
            child: AnimatedBottomContent(
              bgColor: Colors.white,
              contentKey: const ValueKey("chat_behind_sheet"),
              child: BehindSccreenFlow(
                user: state.user,
                SheetState: SheetState,
                // state: ShowChat(s),
              ),
            ),
          ),
        },
        if (SheetState.selectedSheet == Chatsheetmanage.half) ...{
          Chatheaderflow(receiverUser: state.user, sheetState: SheetState),
          Expanded(
            child: AnimatedBottomContent(
              bgColor: Colors.white,
              contentKey: const ValueKey("chat_sheet"),
              child: ChatFlowScreen(
                receiverUser: state.user,
                sheetState: SheetState,
              ),
            ),
          ),
        },
      ],
    );
    // }
    // )
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
            bgColor: Colors.white,
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
                _StatItem(
                  value: "${state.user.friendIds?.length ?? 0}",
                  label: "FRIENDS",
                ),
                _VerticalDivider(),

                _StatItem(value: "${state.dropsCount ?? 0}", label: "DROPS"),
                _VerticalDivider(),

                _StatItem(
                  value: "${state.user.rating.toStringAsFixed(1)}",
                  label: "RATE",
                ),
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

// """""" drop methods

class _DropCard extends StatefulWidget {
  final UserModel user;
  final DropModel drop;
  final String currentUserId;

  const _DropCard({
    required this.user,
    required this.drop,
    required this.currentUserId,
  });

  @override
  State<_DropCard> createState() => _DropCardState();
}

class _DropCardState extends State<_DropCard> {
  late DropModel drop;

  @override
  void initState() {
    super.initState();
    drop = widget.drop;
  }

  bool isFriend() {
    return widget.user.friendIds?.contains(widget.drop.userId) ?? false;
  }

  void toggleLikeOptimistic() async {
    final currentUserId = context.read<CurrentUserCubit>().state!.uid;

    final isLiked = drop.likedBy.contains(currentUserId);

    List<String> updatedLikedBy = List.from(drop.likedBy);

    if (isLiked) {
      updatedLikedBy.remove(currentUserId);
    } else {
      updatedLikedBy.add(currentUserId);
    }

    /// 🔥 INSTANT UI UPDATE
    setState(() {
      drop = drop.copyWith(
        likedBy: updatedLikedBy,
        likeCount: updatedLikedBy.length,
      );
    });

    try {
      await FirebaseFirestore.instance.collection('posts').doc(drop.id).update({
        'likedBy': isLiked
            ? FieldValue.arrayRemove([currentUserId])
            : FieldValue.arrayUnion([currentUserId]),
        'likeCount': updatedLikedBy.length,
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }

  Future<void> _deleteDrop(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.drop.id)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Drop deleted")));
    } catch (e) {
      print("DELETE ERROR: $e");
    }
  }

  DropSarvice dropSarvice = DropSarvice();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 USER ROW
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (widget.drop.userAvatar.isNotEmpty)
                    ? NetworkImage(widget.drop.userAvatar)
                    : null,
                child: widget.drop.userAvatar.isEmpty
                    ? Text(
                        widget.drop.userName[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.drop.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          _timeAgo(widget.drop.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.drop.userEmail.isNotEmpty
                          ? "@${widget.drop.userEmail}"
                          : "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.drop.userId == widget.currentUserId)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteDrop(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'delete', child: Text("Delete")),
                  ],
                ),

              /// ➕ ADD FRIEND BUTTON
              // if (!isAlreadyFriend && drop.userId != currentUserId)
              if (widget.drop.userId != widget.currentUserId)
                BlocBuilder<FriendCubit, FriendState>(
                  builder: (context, state) {
                    final currentUser = context.watch<CurrentUserCubit>().state;

                    if (currentUser == null) return const SizedBox();

                    final isFriend =
                        currentUser.friendIds?.contains(widget.drop.userId) ??
                        false;

                    return GestureDetector(
                      onTap: () {
                        print("FRIENDS: ${currentUser.friendIds}");
                        print("TARGET: ${widget.drop.userId}");
                        print("CLICKED"); // 👈 add this
                        context.read<FriendCubit>().toggleFriend(
                          myId: currentUser.uid,
                          targetUserId: widget.drop.userId,
                          context: context,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isFriend ? Colors.grey.shade300 : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isFriend ? "Unfriend" : "InFriend",
                          style: TextStyle(
                            color: isFriend ? Colors.black : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 14),

          /// 📝 TEXT
          Text(
            widget.drop.text,
            style: const TextStyle(fontSize: 15.5, height: 1.4),
          ),

          const SizedBox(height: 14),

          /// ❤️ ACTION ROW
          Row(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.drop.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final List likedBy = data['likedBy'] ?? [];
                  final int likeCount = data['likeCount'] ?? 0;

                  final isLiked = likedBy.contains(widget.currentUserId);

                  return GestureDetector(
                    onTap: toggleLikeOptimistic,
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isLiked ? Colors.red : Colors.black,
                        ),
                        const SizedBox(width: 6),
                        Text("$likeCount"),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(width: 20),

              /// 💬 COMMENT BUTTON
              GestureDetector(
                onTap: () => _openComments(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 20),
                        SizedBox(width: 6),
                        Text("Comment"),
                      ],
                    ),

                    /// 🔥 LAST COMMENT PREVIEW
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.drop.id) // ✅ FIXED
                          .collection('comments')
                          .orderBy('createdAt', descending: true)
                          .limit(1) // ✅ only last comment
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(); // cleaner UI
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Text(
                            "No comments yet",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          );
                        }

                        final lastComment = docs.first;

                        return Text(
                          lastComment['text'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔥 ADD FRIEND LOGIC
  void _addFriend(BuildContext context) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.drop.userId);

    await userRef.set({
      'friendsId': FieldValue.arrayUnion([widget.currentUserId]),
    }, SetOptions(merge: true)); // ✅ handles null case

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Friend added")));
  }

  /// 💬 OPEN COMMENTS
  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(dropId: widget.drop.id),
    );
  }
}

// ''''''

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes == 0) return "Just Now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  return "${diff.inDays}d ago";
}

class CommentSheet extends StatelessWidget {
  final String dropId;

  const CommentSheet({required this.dropId});
  Future<void> _deleteComment(
    BuildContext context,
    String dropId,
    String commentId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(dropId)
          .collection('comments')
          .doc(commentId)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Comment deleted")));
    } catch (e) {
      print("DELETE COMMENT ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final currentUser = context.read<CurrentUserCubit>().state;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          /// HANDLE
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Text(
            "Comments",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          /// 🔥 COMMENTS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(dropId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No comments yet"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(data['userName'][0].toUpperCase()),
                      ),
                      title: Text(data['userName']),
                      subtitle: Text(data['text']),

                      /// ✅ SHOW DELETE ONLY FOR OWNER
                      trailing: data['userId'] == currentUser?.uid
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteComment(context, dropId, data.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text("Delete"),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),

          /// ✍️ INPUT FIELD
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 12,
              right: 12,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                /// SEND BUTTON
                GestureDetector(
                  onTap: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;

                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(dropId)
                        .collection('comments')
                        .add({
                          'userId': currentUser!.uid,
                          'userName': currentUser.name,
                          'userEmail': currentUser.email,
                          'text': text,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                    controller.clear();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
