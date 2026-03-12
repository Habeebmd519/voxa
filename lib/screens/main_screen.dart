import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:voxa/core/navigation/home_nav_controller.dart';
import 'package:voxa/core/widgets/bottom_content.dart';
import 'package:voxa/feature/service/auth_service.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/task/top_toggle_system/enum.dart';
import 'package:voxa/feature/task/user/screen/chat_screen.dart';
import 'package:voxa/screens/screen_home.dart';
// import 'package:voxa/screens/screen_login.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:voxa/screens/screen_login.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // int _selectedIndex = 0;
  AuthService authService = AuthService();

  final _page = [ScreenHome(), ScreenHome(), ScreenHome(), ScreenHome()];

  @override
  Widget build(BuildContext context) {
    Future<void> _logout(BuildContext context) async {
      try {
        await authService.logout();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate after logout
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnimatedLoginScreen()),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
    // final currentUser = FirebaseAuth.instance.currentUser;
    // final uid = currentUser?.uid;

    // getName() async {
    //   final doc = await FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(uid)
    //       .get();
    //   return doc['name'];
    // }

    // final userName = geName(); // "Habeeb"

    return ValueListenableBuilder<int>(
      valueListenable: HomeNavController.index,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            centerTitle: true,

            backgroundColor: Color.fromARGB(255, 175, 218, 111),
            leading: BlocBuilder<SheetCubit, SheetState>(
              builder: (context, state) {
                return BlocBuilder<TopBarCubit, TopMode>(
                  builder: (context, mode) {
                    IconData icon;

                    // 🎯 PRIORITY 1 → Chat screen
                    if (state is ShowChat) {
                      icon = Icons.arrow_back;
                    }
                    // 🎯 PRIORITY 2 → Search or Add mode
                    else if (mode == TopMode.search || mode == TopMode.add) {
                      icon = Icons.close;
                    }
                    // 🎯 NORMAL
                    else {
                      icon = Icons.menu;
                    }
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: IconButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 79, 127, 47),
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            Colors.white,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        icon: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(icon),
                        ),
                        onPressed: () {
                          if (state is ShowChat) {
                            context.read<SheetCubit>().openUsers();
                            context.read<ChatsheetmanageCubit>()
                              ..changeSheet(Chatsheetmanage.full);

                            return;
                          }
                          if (mode == TopMode.normal) {
                            _logout(context);
                          }
                          if (mode == TopMode.search) {
                            context.read<TopBarCubit>().reset();
                          }
                          if (mode == TopMode.add) {
                            context.read<TopBarCubit>().closeAdd();
                          }

                          // if (mode == TopMode.search)
                        },
                      ),
                    );
                  },
                );
              },
            ),
            title: BlocBuilder<SheetCubit, SheetState>(
              builder: (context, state) {
                return BlocBuilder<TopBarCubit, TopMode>(
                  builder: (context, mode) {
                    if (state is ShowChat) {
                      return Column(
                        children: [
                          Text("${state.user.name}"),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(state.user.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox();

                              final data =
                                  snapshot.data!.data()
                                      as Map<String, dynamic>?;

                              final isOnline = data?['isOnline'] ?? false;
                              final lastSeen = data?['lastSeen'] as Timestamp?;

                              String statusText;

                              if (isOnline) {
                                statusText = "Online";
                              } else if (lastSeen != null) {
                                statusText =
                                    "Last seen ${DateFormat('h:mm a').format(lastSeen.toDate())}";
                              } else {
                                statusText = "Offline";
                              }

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isOnline)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOnline
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }
                    if (mode == TopMode.search) {
                      return const Text("Add Users");
                    }

                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      return const Text("Hi...");
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("Hi...");
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text("Hi...");
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final userName = data?['name'] ?? '';

                        return Text("Hi, $userName");
                      },
                    );
                  },
                );
              },
            ),
            titleSpacing: 0,
          ),

          body: _page[selectedIndex],

          bottomNavigationBar: BlocBuilder<SheetCubit, SheetState>(
            builder: (context, state) {
              if (state is ShowChat) {
                return const SizedBox(); // 👈 HIDE NAV BAR
              }
              return MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: CrystalNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => HomeNavController.setIndex = index,
                  height: 70,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  unselectedItemColor: Colors.grey,
                  selectedItemColor: Color.fromARGB(255, 175, 218, 111),

                  items: [
                    CrystalNavigationBarItem(
                      icon: Icons.chat_bubble,
                      unselectedIcon: Icons.chat_bubble_outline,
                    ),
                    CrystalNavigationBarItem(
                      icon: Icons.settings_voice_rounded,
                      unselectedIcon: Icons.settings_voice_outlined,
                    ),
                    CrystalNavigationBarItem(
                      icon: Icons.video_call_rounded,
                      unselectedIcon: Icons.video_call_outlined,
                    ),
                    CrystalNavigationBarItem(
                      icon: Icons.person_rounded,
                      unselectedIcon: Icons.person_outline,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
