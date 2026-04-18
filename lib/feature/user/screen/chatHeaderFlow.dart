import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:voxa/core/widgets/bottom_content.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';
import 'package:voxa/feature/user/screen/chat_screen.dart';
import 'package:voxa/feature/user/utils/behind_screen_flow.dart/behind_sccreen_flow.dart';
import 'package:voxa/feature/user/widget/behind_top_swction.dart';
import 'package:voxa/feature/user/widget/chat_hedear.dart';

class Chatheaderflow extends StatelessWidget {
  final UserModel receiverUser;
  final ChatsheetmanageState sheetState;

  const Chatheaderflow({
    super.key,
    required this.receiverUser,
    required this.sheetState,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        UserModel fullUser = receiverUser;
        if (snapshot.hasData && snapshot.data?.data() != null) {
          try {
            fullUser = UserModel.fromMap(
              snapshot.data!.data() as Map<String, dynamic>,
            );
          } catch (e) {
            debugPrint("Error parsing full user: $e");
          }
        }

        return Column(
          children: [
            ChatHeader(user: fullUser),
            // Expanded(child: ChatScreen(receiverUser: fullUser)),
          ],
        );
      },
    );
  }
}
