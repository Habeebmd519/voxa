import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:voxa/feature/chat/chat_cubit/chat_cubit.dart';

// import 'package:voxa/core/widgets/bottom_content.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/user/bloc/UserCubit.dart';

import '../utils/chat_utils.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiverUser;

  const ChatScreen({super.key, required this.receiverUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  late String chatId;

  @override
  void initState() {
    super.initState();

    chatId = generateChatId(currentUser.uid, widget.receiverUser.uid);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureChatExists();
    });
    context.read<ChatCubitt>().markChatAsRead(
      chatId: chatId,
      receiverId: widget.receiverUser.uid,
    );
  }

  void sendMessage(currentUserId) {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    context.read<ChatCubitt>().sendMessage(
      chatId: chatId,
      receiverId: widget.receiverUser.uid,
      text: text,
      currentUserId: currentUserId,
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // print("AUTH USER 👉 ${FirebaseAuth.instance.currentUser}");

    return BlocBuilder<SheetCubit, SheetState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(225, 244, 248, 241),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: firestore
                        .collection('chats')
                        .doc(chatId)
                        .snapshots(),
                    builder: (context, chatSnapshot) {
                      if (chatSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (chatSnapshot.hasError) {
                        print("CHAT ERROR 👉 ${chatSnapshot.error}");
                        return Center(
                          child: Text(chatSnapshot.error.toString()),
                        );
                      }

                      // 🚨 If chat doesn't exist yet
                      if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
                        return const Center(
                          child: Text("Start conversation 👋"),
                        );
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection('chats')
                            .doc(chatId)
                            .collection('messages')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, msgSnapshot) {
                          if (msgSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (msgSnapshot.hasError) {
                            print("MSG ERROR 👉 ${msgSnapshot.error}");
                            return Center(
                              child: Text(msgSnapshot.error.toString()),
                            );
                          }
                          if (msgSnapshot.hasData &&
                              msgSnapshot.data!.docs.isNotEmpty) {
                            context.read<ChatCubitt>().markChatAsRead(
                              chatId: chatId,
                              receiverId: widget.receiverUser.uid,
                            );
                          }

                          final messages = msgSnapshot.data!.docs;

                          if (messages.isEmpty) {
                            return const Center(
                              child: Text("No messages yet 👋"),
                            );
                          }

                          return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe =
                                  message['senderId'] == currentUser.uid;
                              final timestamp =
                                  message['timestamp'] as Timestamp?;
                              final timeString = timestamp != null
                                  ? DateFormat(
                                      'h:mm a',
                                    ).format(timestamp.toDate())
                                  : '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    /// RECEIVER AVATAR
                                    if (!isMe)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              widget.receiverUser.photoUrl !=
                                                      null &&
                                                  widget
                                                      .receiverUser
                                                      .photoUrl!
                                                      .isNotEmpty
                                              ? NetworkImage(
                                                  widget.receiverUser.photoUrl!,
                                                )
                                              : null,
                                          child:
                                              widget.receiverUser.photoUrl ==
                                                  null
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                      ),

                                    /// MESSAGE BUBBLE
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.70,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? const Color(0xFF6FAF3A)
                                                : Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(
                                                22,
                                              ),
                                              topRight: const Radius.circular(
                                                22,
                                              ),
                                              bottomLeft: isMe
                                                  ? const Radius.circular(22)
                                                  : const Radius.circular(4),
                                              bottomRight: isMe
                                                  ? const Radius.circular(4)
                                                  : const Radius.circular(22),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.08,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              /// TEXT
                                              Text(
                                                message['text'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isMe
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),

                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    timeString,
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      color: isMe
                                                          ? Colors.white70
                                                          : Colors
                                                                .grey
                                                                .shade600,
                                                    ),
                                                  ),
                                                  if (isMe) ...[
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                      Icons.done_all,
                                                      size: 10,
                                                      color: Colors.white70,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          // return Center(child: CircularProgressIndicator());
                        },
                      );
                    },
                  ),
                ),

                // Input Area
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      BlocBuilder<ChatsheetmanageCubit, ChatsheetmanageState>(
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              final cubit = context
                                  .read<ChatsheetmanageCubit>();

                              if (state.selectedSheet == Chatsheetmanage.full) {
                                cubit.changeSheet(Chatsheetmanage.half);
                              } else if (state.selectedSheet ==
                                  Chatsheetmanage.half) {
                                cubit.changeSheet(Chatsheetmanage.zero);
                              } else {
                                cubit.changeSheet(Chatsheetmanage.full);
                              }
                            },
                            child: Container(
                              height: 45,
                              width: 45,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 79, 127, 47),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFA5D6A7),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hint: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(),
                                        SizedBox(),
                                        SizedBox(),
                                        SizedBox(),
                                        SizedBox(),
                                        Text("Type a message..."),

                                        SizedBox(),
                                      ],
                                    ),
                                    // hintText: "Type a message...",
                                    // hintStyle: TextStyle(fontSize: 12),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const Text("😊", style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Container(
                        height: 45,
                        width: 45,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 79, 127, 47),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            sendMessage(currentUserId);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _ensureChatExists() async {
    final chatRef = firestore.collection('chats').doc(chatId);

    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        'participants': [currentUser.uid, widget.receiverUser.uid],
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'lastSenderId': '',
      });
    }
  }
}
