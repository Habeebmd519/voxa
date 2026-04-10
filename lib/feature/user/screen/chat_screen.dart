import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:voxa/core/hive/pressentation/models/user_hive_model.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/chat/chat_cubit/chat_cubit.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';
import 'package:voxa/feature/user/screen/chat_screen_shimmer_loading.dart';
import 'package:voxa/feature/user/widget/quckle_dialog.dart';
import 'package:voxa/feature/user/widget/show_premuim_dialog.dart';

import '../utils/chat_utils.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiverUser;

  const ChatScreen({super.key, required this.receiverUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  // final currentUser = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  late String chatId;

  // ── Multi-select state ─────────────────────
  ValueNotifier<Set<String>> selectedMessages = ValueNotifier({});
  ValueNotifier<bool> isSelectionMode = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return; // ✅ just return (no null)

    chatId = generateChatId(currentUser.uid, widget.receiverUser.uid);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _ensureChatExists();

      context.read<ChatCubitt>().markChatAsRead(
        chatId: chatId,
        receiverId: widget.receiverUser.uid,
      );
    });
  }

  // ── Selection helpers ──────────────────────
  void _enterSelectionMode(String messageId, bool isMe) {
    if (!isMe) return;

    isSelectionMode.value = true;

    final current = selectedMessages.value;
    current.add(messageId);

    selectedMessages.value = {...current}; // ✅ trigger update
  }

  void _toggleSelection(String messageId, bool isMe) {
    if (!isMe) return;

    final current = selectedMessages.value;

    if (current.contains(messageId)) {
      current.remove(messageId);
    } else {
      current.add(messageId);
    }

    selectedMessages.value = {...current};

    if (selectedMessages.value.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void _cancelSelection() {
    selectedMessages.value = {};
    isSelectionMode.value = false;
  }

  // ── Bulk delete selected messages ──────────
  Future<void> _deleteSelectedMessages() async {
    if (selectedMessages.value.isEmpty) return;

    final batch = firestore.batch();
    for (final id in selectedMessages.value) {
      final ref = firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(id);
      batch.delete(ref);
    }
    await batch.commit();

    final count = selectedMessages.value.length;
    _cancelSelection();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count message${count > 1 ? 's' : ''} deleted'),
          backgroundColor: const Color(0xFF2A4A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Single delete (your original) ─────────
  Future<void> deleteDeal(String dealId, String dealTitle) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(dealId)
        .delete()
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${dealTitle} deleted'),
                backgroundColor: const Color(0xFF2A4A1A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
  }

  void showDeleteDialog(BuildContext context, String dealId, String dealTitle) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  "Delete Deal",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                const Text(
                  "Are you sure?",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF4F7F2F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Delete
                    GestureDetector(
                      onTap: () {
                        deleteDeal(dealId, dealTitle);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Send message ───────────────────────────
  void sendMessage(String currentUserId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubitt>().sendMessage(
      chatId: chatId,
      receiverId: widget.receiverUser.uid,
      text: text,
      currentUserId: currentUserId,
    );
    HiveServices hiveServices = HiveServices();
    await hiveServices.saveOrUpdateUser(widget.receiverUser, text);
    await hiveServices.saveOrUpdateUser(widget.receiverUser, text);

    print("✅ SAVED: ${widget.receiverUser.uid}");
    print("📦 BOX DATA: ${Hive.box<UserHiveModel>('users').values.toList()}");
    _messageController.clear();
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final currentUserId = user.uid;

    return BlocBuilder<SheetCubit, SheetState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          bottom: true,
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(225, 244, 248, 241),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 0.8),
              child: Column(
                children: [
                  // ── Online status ─────────────────────────
                  Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: user == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.receiverUser.uid)
                                .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                  ),

                  // ── Message list ──────────────────────────
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: user == null
                          ? null
                          : firestore
                                .collection('chats')
                                .doc(chatId)
                                .snapshots(),
                      builder: (context, chatSnapshot) {
                        if (chatSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: ChatShimmer());
                        }
                        if (chatSnapshot.hasError) {
                          return Center(
                            child: Text(chatSnapshot.error.toString()),
                          );
                        }
                        if (!chatSnapshot.hasData ||
                            !chatSnapshot.data!.exists) {
                          return const Center(
                            child: Text("Start conversation 👋"),
                          );
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: user == null
                              ? null
                              : firestore
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
                              return Center(
                                child: Text(msgSnapshot.error.toString()),
                              );
                            }
                            // if (msgSnapshot.hasData &&
                            //     msgSnapshot.data!.docs.isNotEmpty) {
                            //   context.read<ChatCubitt>().markChatAsRead(
                            //     chatId: chatId,
                            //     receiverId: widget.receiverUser.uid,
                            //   );
                            // }
                            if (msgSnapshot.hasData &&
                                msgSnapshot.data!.docs.isNotEmpty) {
                              final latestMessage =
                                  msgSnapshot.data!.docs.first;
                              final data =
                                  latestMessage.data() as Map<String, dynamic>;

                              final senderId = data['senderId'];
                              final text = data['text'] ?? '';

                              if (senderId != currentUserId) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(senderId)
                                    .get()
                                    .then((doc) {
                                      final sender = UserModel.fromMap(
                                        doc.data()!,
                                      );
                                    });
                              }
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
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                if (currentUser == null) return SizedBox();
                                final message = messages[index];
                                final data =
                                    message.data() as Map<String, dynamic>;
                                final isMe =
                                    data['senderId'] == currentUser.uid;
                                final timestamp =
                                    data['timestamp'] as Timestamp?;
                                final timeString = timestamp != null
                                    ? DateFormat(
                                        'h:mm a',
                                      ).format(timestamp.toDate())
                                    : '';
                                context
                                    .read<ChatCubitt>()
                                    .handleIncomingMessage(data);
                                // Deal cards – untouched
                                if (data['type'] == 'deal') {
                                  return dealCard(
                                    data,
                                    chatId,
                                    currentUser.uid,
                                  );
                                }
                                if (data['type'] == 'premium_deal') {
                                  return premiumDealCard(
                                    data,
                                    chatId,
                                    currentUser.uid,
                                  );
                                }

                                // ── Normal message bubble with
                                //    multi-select + shake ────────────
                                final messageId = message.id;
                                // final isSelected = selectedMessages.value
                                //     .contains(messageId);
                                return ValueListenableBuilder<Set<String>>(
                                  valueListenable: selectedMessages,
                                  builder: (context, selected, _) {
                                    final isSelected = selected.contains(
                                      messageId,
                                    );

                                    return ValueListenableBuilder<bool>(
                                      valueListenable: isSelectionMode,
                                      builder: (context, isSelection, __) {
                                        return _ShakableBubble(
                                          key: ValueKey(messageId),
                                          messageId: messageId,
                                          isSelected: isSelected,
                                          isSelectionMode: isSelection,
                                          onLongPress: () {
                                            if (!isMe) return;

                                            HapticFeedback.mediumImpact();

                                            _enterSelectionMode(
                                              messageId,
                                              isMe,
                                            ); // ✅ ALWAYS trigger
                                          },
                                          onTap: () {
                                            if (!isSelection) return;
                                            _toggleSelection(messageId, isMe);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment: isMe
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                              children: [
                                                if (isSelection && isMe)
                                                  _SelectCircle(
                                                    selected: isSelected,
                                                  ),

                                                if (!isMe) ...[
                                                  const SizedBox(width: 6),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 10,
                                                        ),
                                                    child: CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage:
                                                          widget
                                                                      .receiverUser
                                                                      .photoUrl !=
                                                                  null &&
                                                              widget
                                                                  .receiverUser
                                                                  .photoUrl!
                                                                  .isNotEmpty
                                                          ? NetworkImage(
                                                              widget
                                                                  .receiverUser
                                                                  .photoUrl!,
                                                            )
                                                          : null,
                                                      child:
                                                          widget
                                                                  .receiverUser
                                                                  .photoUrl ==
                                                              null
                                                          ? const Icon(
                                                              Icons.person,
                                                            )
                                                          : null,
                                                    ),
                                                  ),
                                                ],

                                                Flexible(
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 180,
                                                    ),
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.70,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? (isMe
                                                                ? const Color(
                                                                    0xFF3A6A1A,
                                                                  )
                                                                : const Color(
                                                                    0xFFDCEFCC,
                                                                  ))
                                                          : (isMe
                                                                ? const Color(
                                                                    0xFF6FAF3A,
                                                                  )
                                                                : Colors.white),
                                                      borderRadius: BorderRadius.only(
                                                        topLeft:
                                                            const Radius.circular(
                                                              22,
                                                            ),
                                                        topRight:
                                                            const Radius.circular(
                                                              22,
                                                            ),
                                                        bottomLeft: isMe
                                                            ? const Radius.circular(
                                                                22,
                                                              )
                                                            : const Radius.circular(
                                                                4,
                                                              ),
                                                        bottomRight: isMe
                                                            ? const Radius.circular(
                                                                4,
                                                              )
                                                            : const Radius.circular(
                                                                22,
                                                              ),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          data['text'] ?? "",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: isMe
                                                                ? Colors.white
                                                                : Colors
                                                                      .black87,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ── Bottom bar: toolbar ↔ input ───────────
                  ValueListenableBuilder<bool>(
                    valueListenable: isSelectionMode,
                    builder: (context, isSelection, _) {
                      return ValueListenableBuilder<Set<String>>(
                        valueListenable: selectedMessages,
                        builder: (context, selected, __) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: isSelection
                                ? _SelectionToolbar(
                                    key: const ValueKey('toolbar'),
                                    selectedCount: selected.length, // ✅ FIXED
                                    onCancel: _cancelSelection,
                                    onDelete: _deleteSelectedMessages,
                                  )
                                : _buildInputArea(currentUserId),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Input area (your original, unchanged) ──
  Widget _buildInputArea(String currentUserId) {
    return Container(
      key: const ValueKey('input'),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showDealOptions(context, widget.receiverUser.uid),
            child: Container(
              height: 45,
              width: 45,
              decoration: const BoxDecoration(
                color: Color(0xFF4F7F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hint: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              onPressed: () => sendMessage(currentUserId),
            ),
          ),
        ],
      ),
    );
  }

  // ── All your original methods below, untouched ──

  Future<void> _ensureChatExists() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
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

  Future<bool> hasActiveOrPendingDeal() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('type', whereIn: ['deal', 'premium_deal'])
        .where('status', whereIn: ['pending', 'active'])
        .get();
    return snapshot.docs.isNotEmpty;
  }

  void _showDealOptions(BuildContext context, String receiverId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dealOption(
              icon: Icons.flash_on,
              title: "Quick Deal",
              subtitle: "Simple agreement",
              onTap: () async {
                Navigator.pop(context);
                final hasDeal = await hasActiveOrPendingDeal();
                if (hasDeal) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "You already have an active/pending deal 🚫",
                      ),
                    ),
                  );
                  return;
                }
                showQuickDealDialog(context, chatId);
              },
            ),
            _dealOption(
              icon: Icons.workspace_premium,
              title: "Premium Deal",
              subtitle: "Full contract",
              onTap: () async {
                Navigator.pop(context);
                final hasDeal = await hasActiveOrPendingDeal();
                if (hasDeal) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "You already have an active/pending deal 🚫",
                      ),
                      backgroundColor: const Color(0xFF2A4A1A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  return;
                }
                showPremiumDealDialog(context, chatId, receiverId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dealOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  void _showCreateDealDialog(BuildContext context, String receiverId) {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        DateTime? endDate;
        return AlertDialog(
          title: const Text("Create Deal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => endDate = picked);
                },
                child: Text(
                  endDate == null
                      ? "Select Deadline"
                      : DateFormat('dd MMM').format(endDate!),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) return;
                final docRef = FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .doc();
                await docRef.set({
                  "id": docRef.id,
                  "title": titleCtrl.text,
                  "price": priceCtrl.text,
                  "status": "pending",
                  "startDate": null,
                  "deadline": endDate?.toIso8601String(),
                  "type": "deal",
                  "senderId": currentUser.uid,
                  "timestamp": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  // void _showPremiumDealDialog(BuildContext context, String receiverId) {
  //   final titleCtrl = TextEditingController();
  //   final descCtrl = TextEditingController();
  //   List<Map<String, dynamic>> milestones = [];
  //   DateTime? endDate;
  //   showDialog(
  //     context: context,
  //     builder: (_) => StatefulBuilder(
  //       builder: (context, setState) => AlertDialog(
  //         title: const Text("Premium Deal"),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               TextField(
  //                 controller: titleCtrl,
  //                 decoration: const InputDecoration(labelText: "Title"),
  //               ),
  //               TextField(
  //                 controller: descCtrl,
  //                 decoration: const InputDecoration(labelText: "Description"),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   final picked = await showDatePicker(
  //                     context: context,
  //                     initialDate: DateTime.now().add(const Duration(days: 1)),
  //                     firstDate: DateTime.now(),
  //                     lastDate: DateTime(2100),
  //                   );
  //                   if (picked != null) setState(() => endDate = picked);
  //                 },
  //                 child: Text(
  //                   endDate == null
  //                       ? "Select Deadline"
  //                       : DateFormat('dd MMM').format(endDate!),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   final mTitle = TextEditingController();
  //                   final mAmount = TextEditingController();
  //                   showDialog(
  //                     context: context,
  //                     builder: (_) => AlertDialog(
  //                       title: const Text("Add Milestone"),
  //                       content: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           TextField(
  //                             controller: mTitle,
  //                             decoration: const InputDecoration(
  //                               labelText: "Title",
  //                             ),
  //                           ),
  //                           TextField(
  //                             controller: mAmount,
  //                             keyboardType: TextInputType.number,
  //                             decoration: const InputDecoration(
  //                               labelText: "Amount",
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       actions: [
  //                         TextButton(
  //                           onPressed: () => Navigator.pop(context),
  //                           child: const Text("Cancel"),
  //                         ),
  //                         ElevatedButton(
  //                           onPressed: () {
  //                             setState(() {
  //                               milestones.add({
  //                                 "title": mTitle.text,
  //                                 "amount": int.parse(mAmount.text),
  //                                 "status": "pending",
  //                                 "deadline": endDate?.toIso8601String(),
  //                                 "startDate": null,
  //                               });
  //                             });
  //                             Navigator.pop(context);
  //                           },
  //                           child: const Text("Add"),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //                 child: const Text("Add Milestone"),
  //               ),
  //               Column(
  //                 children: milestones
  //                     .map(
  //                       (m) => ListTile(
  //                         title: Text(m['title']),
  //                         trailing: Text("₹${m['amount']}"),
  //                       ),
  //                     )
  //                     .toList(),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Cancel"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               final docRef = FirebaseFirestore.instance
  //                   .collection('chats')
  //                   .doc(chatId)
  //                   .collection('messages')
  //                   .doc();
  //               final total = milestones.fold<int>(
  //                 0,
  //                 (sum, m) => sum + (m['amount'] as int),
  //               );
  //               await docRef.set({
  //                 "id": docRef.id,
  //                 "type": "premium_deal",
  //                 "title": titleCtrl.text,
  //                 "description": descCtrl.text,
  //                 "totalPrice": total,
  //                 "milestones": milestones,
  //                 "deadline": endDate?.toIso8601String(),
  //                 "startDate": null,
  //                 "status": "pending",
  //                 "senderId": currentUser.uid,
  //                 "timestamp": FieldValue.serverTimestamp(),
  //               });
  //               Navigator.pop(context);
  //             },
  //             child: const Text("Send Deal"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget premiumDealCard(
    Map<String, dynamic> deal,
    String chatId,
    String currentUserId,
  ) {
    final isSender = deal['senderId'] == currentUserId;
    final status = deal['status'] ?? "pending";
    final List milestones = deal['milestones'] ?? [];
    final start = deal['startDate'] != null
        ? DateFormat('dd MMM').format(DateTime.parse(deal['startDate']))
        : "Not started";
    final end = deal['deadline'] != null
        ? DateFormat('dd MMM').format(DateTime.parse(deal['deadline']))
        : "-";
    Color statusColor;
    if (status == "pending") {
      statusColor = Colors.orange;
    } else if (status == "active") {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.blue;
    }

    return GestureDetector(
      onLongPress: () {
        if (deal['senderId'] == currentUserId) {
          showDeleteDialog(context, deal['id'], deal['title']);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.amber),
                const SizedBox(width: 6),
                const Text(
                  "Premium Deal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deal['title'] ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if ((deal['description'] ?? "").isNotEmpty)
              Text(
                deal['description'],
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            const SizedBox(height: 10),
            Text(
              "Total: ₹ ${deal['totalPrice'] ?? 0}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: milestones.map((m) {
                final mStatus = m['status'] ?? "pending";
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          m['title'] ?? "",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        "₹${m['amount']}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        mStatus == "completed"
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: mStatus == "completed"
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (status == "pending" && !isSender)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => acceptDeal(chatId, deal['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => rejectDeal(chatId, deal['id']),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  "$start → $end",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (status == "pending" && isSender)
              const Text(
                "Waiting for response ⏳",
                style: TextStyle(color: Colors.grey),
              ),
            if (status == "active")
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Deal in progress 🚀",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            if (status == "completed")
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Completed ✅",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  Firestore helpers (your originals, unchanged)
  // ══════════════════════════════════════════════
  Widget dealCard(
    Map<String, dynamic> deal,
    String chatID,
    String currentUserId,
  ) {
    final status = deal['status'];
    final start = deal['startDate'] != null
        ? DateFormat('dd MMM').format(DateTime.parse(deal['startDate']))
        : "Not started";
    final end = deal['deadline'] != null
        ? DateFormat('dd MMM').format(DateTime.parse(deal['deadline']))
        : "-";
    Color statusColor;
    if (status == "pending") {
      statusColor = Colors.orange;
    } else if (status == "active") {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.blue;
    }

    return GestureDetector(
      onLongPress: () {
        if (deal['senderId'] == currentUserId) {
          showDeleteDialog(context, deal['id'], deal['title']);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work, color: Colors.green, size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Deal Proposal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deal['title'],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              "₹ ${deal['price']}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  start,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.flag, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  end,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (status == "pending" && deal['senderId'] == currentUserId)
              const Text(
                "Waiting for response ⏳",
                style: TextStyle(color: Colors.grey),
              ),
            if (status == "pending" && deal['senderId'] != currentUserId)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => acceptDeal(chatID, deal['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => rejectDeal(chatID, deal['id']),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            if (status == "active")
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Deal in progress 🚀",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            if (status == "completed")
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Completed ✅",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  _ShakableBubble
//  Wraps any child with long-press, tap, shake,
//  and selection highlight logic.
// ══════════════════════════════════════════════
class _ShakableBubble extends StatefulWidget {
  final String messageId;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Widget child;

  const _ShakableBubble({
    super.key,
    required this.messageId,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onLongPress,
    required this.onTap,
    required this.child,
  });

  @override
  State<_ShakableBubble> createState() => _ShakableBubbleState();
}

class _ShakableBubbleState extends State<_ShakableBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ShakableBubble old) {
    super.didUpdateWidget(old);
    // Trigger shake whenever this bubble becomes selected
    if (widget.isSelected && !old.isSelected) {
      _controller.forward(from: 0);
    }
  }

  double get _offsetX {
    final t = _shake.value;
    // Damped sine: left/right wobble that dies out
    return sin(t * pi * 5) * 6 * (1 - t);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) =>
            Transform.translate(offset: Offset(_offsetX, 0), child: child),
        child: widget.child,
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  _SelectCircle  –  animated checkbox
// ══════════════════════════════════════════════
class _SelectCircle extends StatelessWidget {
  final bool selected;
  const _SelectCircle({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF5A9A3A) : Colors.transparent,
        border: Border.all(color: const Color(0xFF5A9A3A), width: 2),
      ),
      child: selected
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}

// ══════════════════════════════════════════════
//  _SelectionToolbar
// ══════════════════════════════════════════════
class _SelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _SelectionToolbar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A4A1A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFCCE8AA), fontSize: 14),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$selectedCount selected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: selectedCount > 0 ? onDelete : null,
            child: AnimatedOpacity(
              opacity: selectedCount > 0 ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC0392B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> acceptDeal(String chatId, String dealId) async {
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(dealId)
      .update({
        "status": "active",
        "startDate": DateTime.now().toIso8601String(),
      });
}

Future<void> rejectDeal(String chatId, String dealId) async {
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(dealId)
      .update({"status": "rejected"});
}
