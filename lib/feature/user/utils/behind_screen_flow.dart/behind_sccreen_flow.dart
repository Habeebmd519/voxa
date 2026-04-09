import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';
import 'package:voxa/feature/user/screen/chat_behind_screen.dart';
import 'package:voxa/feature/user/widget/bounce_arrow.dart';

class BehindSccreenFlow extends StatelessWidget {
  UserModel user;
  ChatsheetmanageState SheetState;
  ShowChat state;
  BehindSccreenFlow({
    super.key,
    required this.user,
    required this.SheetState,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🔥 BACKGROUND → PROFILE SHOWCASE
        Positioned.fill(child: ChatProfileBackground(user: state.user)),

        /// 🔥 FOREGROUND (The Arrow)
        if (SheetState.selectedSheet == Chatsheetmanage.zero)
          Align(
            alignment: Alignment.bottomCenter, // Moves it to the bottom
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 40.0,
              ), // Adjust this value to set the height from bottom
              child: InkWell(
                onTap: () {
                  context.read<ChatsheetmanageCubit>().changeSheet(
                    Chatsheetmanage.half,
                  );
                },
                child: const BouncingArrow(),
              ),
            ),
          ),
      ],
    );
  }
}
