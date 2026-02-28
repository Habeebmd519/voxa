import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/core/navigation/home_nav_controller.dart';
import 'package:voxa/feature/chat_model.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:voxa/feature/task/local_search/cubit/search_togle_cubit.dart';
import 'package:voxa/feature/task/top_toggle_system/cubit/cubit.dart';
import 'package:voxa/feature/task/top_toggle_system/enum.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HomeNavController.index,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 175, 218, 111),
          body: index == 0
              ? Column(
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
                                        : MediaQuery.of(context).size.width *
                                              0.8,

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
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                                child: Text(
                                                  "Search for anyone...",
                                                ),
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
                                    TopMode.addPreparing => 0, // shrinking
                                    TopMode.add => 0, // hidden
                                    TopMode.closingAdd =>
                                      0, // wait until field collapses
                                    _ => 50,
                                  },
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: mode == TopMode.normal
                                        ? GestureDetector(
                                            key: const ValueKey("addButton"),
                                            onTap: () {
                                              context
                                                  .read<TopBarCubit>()
                                                  .showAdd();
                                            },
                                            child: const CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Colors.white,
                                              child: Icon(Icons.add),
                                            ),
                                          )
                                        : const SizedBox(
                                            key: ValueKey("empty"),
                                          ),
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
                      child: animatedBottomContent(
                        ListView.builder(
                          itemCount: chatData.length,
                          itemBuilder: (context, i) {
                            final chat = chatData[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFAFDA6F),
                                child: Text(chat.name[0]),
                              ),
                              title: Text(chat.name),
                              subtitle: Text(chat.lastMessage),
                            );
                          },
                        ),
                        const ValueKey("chat_sheet"),
                      ),
                    ),
                  ],
                )
              : index == 1
              ? Column(
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
                                  color: const Color.fromARGB(
                                    255,
                                    175,
                                    218,
                                    111,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/walkyTalkyBg.png",
                                    ),
                                    fit: BoxFit.cover,
                                    opacity:
                                        0.25, // important: avoids overpowering text
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
                      child: animatedBottomContent(
                        ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, i) {
                            return const ListTile(title: Text("History"));
                          },
                        ),
                        const ValueKey("audio_sheet"),
                      ),
                    ),
                  ],
                )
              : index == 2
              ? Column(
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
                                  color: const Color.fromARGB(
                                    255,
                                    175,
                                    218,
                                    111,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage("assets/videoMeetBg.png"),
                                    fit: BoxFit.cover,
                                    opacity:
                                        0.25, // important: avoids overpowering text
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
                      child: animatedBottomContent(
                        ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, i) {
                            return const ListTile(title: Text("History"));
                          },
                        ),
                        const ValueKey("video_sheet"),
                      ),
                    ),
                  ],
                )
              : index == 3
              ? SizedBox(child: Center(child: Text("Profilr")))
              : SizedBox(),
        );
      },
    );
  }

  Widget animatedBottomContent(Widget child, Key key) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      child: Container(
        key: key,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: child,
      ),
    );
  }
}
