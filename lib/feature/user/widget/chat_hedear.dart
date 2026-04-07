import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';

class ChatHeader extends StatelessWidget {
  final UserModel user;

  const ChatHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      // top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(
          children: [
            /// 🔙 BACK BUTTON
            GestureDetector(
              onTap: () {
                context.read<SheetCubit>().openUsers();
                context.read<ChatsheetmanageCubit>().changeSheet(
                  Chatsheetmanage.half,
                );
              },
              child: Container(
                height: 42,
                width: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F7F2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),

            const SizedBox(width: 12),

            /// 👤 USER INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  /// 🔥 REALTIME STATUS
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;

                      final isOnline = data?['isOnline'] ?? false;
                      final lastSeen = data?['lastSeen'] as Timestamp?;

                      String status;

                      if (isOnline) {
                        status = "Online";
                      } else if (lastSeen != null) {
                        status =
                            "Last seen ${DateFormat('h:mm a').format(lastSeen.toDate())}";
                      } else {
                        status = "Offline";
                      }

                      return Row(
                        children: [
                          if (isOnline)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            /// 📞 ACTIONS (optional)
            Row(
              children: [
                IconButton(icon: const Icon(Icons.call), onPressed: () {}),
                IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
