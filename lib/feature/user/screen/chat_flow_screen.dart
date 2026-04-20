import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:synapse/core/widgets/bottom_content.dart';
import 'package:synapse/feature/auth/data/model/user_model.dart';
import 'package:synapse/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:synapse/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';
import 'package:synapse/feature/user/screen/chat_screen.dart';
import 'package:synapse/feature/user/utils/behind_screen_flow.dart/behind_sccreen_flow.dart';
import 'package:synapse/feature/user/widget/behind_top_swction.dart';
import 'package:synapse/feature/user/widget/chat_hedear.dart';

class ChatFlowScreen extends StatelessWidget {
  final UserModel receiverUser;
  final ChatsheetmanageState sheetState;

  const ChatFlowScreen({
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
            // ChatHeader(user: fullUser),
            Expanded(child: ChatScreen(receiverUser: fullUser)),
          ],
        );
      },
    );
  }
}
