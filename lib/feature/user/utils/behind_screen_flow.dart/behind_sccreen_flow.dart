import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/auth/data/model/user_model.dart';
import 'package:synapse/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:synapse/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:synapse/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';
import 'package:synapse/feature/user/screen/chat_behind_screen.dart';
import 'package:synapse/feature/user/widget/bounce_arrow.dart';

class BehindSccreenFlow extends StatelessWidget {
  UserModel user;
  ChatsheetmanageState SheetState;
  // ShowChat state;
  BehindSccreenFlow({
    super.key,
    required this.user,
    required this.SheetState,
    // required this.state,
  });

  @override
  Widget build(BuildContext context) {
    print(" from behind screen flow${user.uid}");
    print(" from behind screen flow${user.place}");
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        UserModel fullUser = user;
        if (snapshot.hasData && snapshot.data?.data() != null) {
          try {
            fullUser = UserModel.fromMap(
              snapshot.data!.data() as Map<String, dynamic>,
            );
          } catch (e) {
            debugPrint("Error parsing full user: $e");
          }
        }
        print("from full user${fullUser.place}");
        return Stack(
          children: [
            /// 🔥 BACKGROUND → PROFILE SHOWCASE
            Positioned.fill(child: ChatProfileBackground(user: fullUser)),

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
      },
    );
  }
}
