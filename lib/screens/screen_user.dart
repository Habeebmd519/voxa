import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/core/widgets/bottom_content.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/task/top_toggle_system/enum.dart';
import 'package:voxa/feature/task/user/bloc/UserCubit.dart';
import 'package:voxa/feature/task/user/bloc/UserState.dart';

class ScreenUser extends StatelessWidget {
  ScreenUser({super.key});

  @override
  Widget build(BuildContext context) {
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
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => ChatScreen(receiverUser: user),
                          //   ),
                          // );
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
}
