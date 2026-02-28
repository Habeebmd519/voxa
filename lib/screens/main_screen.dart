import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voxa/core/navigation/home_nav_controller.dart';

import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/task/top_toggle_system/enum.dart';
import 'package:voxa/screens/screen_home.dart';
// import 'package:voxa/screens/screen_login.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  final profUrl;
  MainScreen({super.key, this.profUrl});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ScreenHome(),
    ScreenHome(),
    ScreenHome(),
    ScreenHome(),
  ];
  @override
  Widget build(BuildContext context) {
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

    print(widget.profUrl);
    return ValueListenableBuilder<int>(
      valueListenable: HomeNavController.index,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 175, 218, 111),
            leading: BlocBuilder<TopBarCubit, TopMode>(
              builder: (context, mode) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 79, 127, 47),
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    icon: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        mode == TopMode.search || mode == TopMode.add
                            ? Icons.close
                            : Icons.menu,
                      ),
                    ),
                    onPressed: () {
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
            ),
            title: BlocBuilder<TopBarCubit, TopMode>(
              builder: (context, mode) {
                return mode == TopMode.search
                    ? Text("Add Users")
                    : FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Hi...");
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Text("Hi...");
                          }
                          final userName = snapshot.data!['name'];
                          return Text("Hi, $userName");
                        },
                      );
              },
            ),
            titleSpacing: 0,
          ),

          body: _pages[selectedIndex],
          bottomNavigationBar: MediaQuery.removePadding(
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
          ),
        );
      },
    );
  }
}
