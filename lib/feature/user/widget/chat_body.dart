import 'package:flutter/material.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/user/screen/chat_screen.dart';

class ChatSheetBody extends StatelessWidget {
  final UserModel user;

  const ChatSheetBody({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4F8F1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          /// DRAG HANDLE
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          /// ⚠️ THIS DOES NOT REBUILD NOW
          Expanded(child: ChatScreen(receiverUser: user)),
        ],
      ),
    );
  }
}
