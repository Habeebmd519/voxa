import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

import 'package:voxa/feature/chat/chat_cubit/chat_cubit.dart';

import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_state.dart';

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
  // send message funtion

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

  //  premuim deal card build
  void _showPremiumDealDialog(BuildContext context, String receiverId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    List<Map<String, dynamic>> milestones = [];
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (_) {
        // DateTime? endDate;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Premium Deal"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                      child: Text(
                        endDate == null
                            ? "Select Deadline"
                            : DateFormat('dd MMM').format(endDate!),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// 🔥 ADD MILESTONE BUTTON
                    ElevatedButton(
                      onPressed: () {
                        final mTitle = TextEditingController();
                        final mAmount = TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text("Add Milestone"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: mTitle,
                                    decoration: const InputDecoration(
                                      labelText: "Title",
                                    ),
                                  ),
                                  TextField(
                                    controller: mAmount,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Amount",
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
                                  onPressed: () {
                                    setState(() {
                                      milestones.add({
                                        "title": mTitle.text,
                                        "amount": int.parse(mAmount.text),
                                        "status": "pending",
                                        "deadline": endDate?.toIso8601String(),
                                        "startDate": null, // optional
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Add"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text("Add Milestone"),
                    ),

                    /// 🔥 SHOW MILESTONES
                    Column(
                      children: milestones
                          .map(
                            (m) => ListTile(
                              title: Text(m['title']),
                              trailing: Text("₹${m['amount']}"),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print(chatId);
                    final docRef = FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .doc();

                    final total = milestones.fold<int>(
                      0,
                      (sum, m) => sum + (m['amount'] as int),
                    );

                    await docRef.set({
                      "id": docRef.id,
                      "type": "premium_deal",
                      "title": titleCtrl.text,
                      "description": descCtrl.text,
                      "totalPrice": total,
                      "milestones": milestones,
                      "deadline": endDate?.toIso8601String(),
                      "startDate": null,
                      "status": "pending",
                      "senderId": currentUser.uid,
                      "timestamp": FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Send Deal"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // check has any deal in pending or active
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
            child: Padding(
              padding: const EdgeInsets.only(top: 0.8),
              child: Column(
                children: [
                  // ChatHeader(user: widget.receiverUser),
                  Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.receiverUser.uid)
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
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: firestore
                          .collection('chats')
                          .doc(chatId)
                          .snapshots(),
                      builder: (context, chatSnapshot) {
                        if (chatSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (chatSnapshot.hasError) {
                          print("CHAT ERROR 👉 ${chatSnapshot.error}");
                          return Center(
                            child: Text(chatSnapshot.error.toString()),
                          );
                        }

                        // 🚨 If chat doesn't exist yet
                        if (!chatSnapshot.hasData ||
                            !chatSnapshot.data!.exists) {
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

                                /// 🔥 DEAL MESSAGE (NEW)
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

                                /// 💬 NORMAL MESSAGE (YOUR ORIGINAL UI - SAFE)
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
                                      /// 👤 RECEIVER AVATAR (KEEP THIS)
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
                                                    widget
                                                        .receiverUser
                                                        .photoUrl!,
                                                  )
                                                : null,
                                            child:
                                                widget.receiverUser.photoUrl ==
                                                    null
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                        ),

                                      /// 💬 MESSAGE BUBBLE (SAFE FIXED)
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
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                /// 🔥 TEXT (SAFE NOW)
                                                Text(
                                                  data['text'] ??
                                                      "", // ✅ FIXED CRASH
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: isMe
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                /// ⏱ TIME + STATUS
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                        GestureDetector(
                          onTap: () {
                            _showDealOptions(context, widget.receiverUser.uid);
                          },
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
                                const Text(
                                  "😊",
                                  style: TextStyle(fontSize: 20),
                                ),
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

  //// premuim deal card build
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

    return Container(
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
          /// 🔥 HEADER
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

          /// 📄 TITLE
          Text(
            deal['title'] ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          /// 📝 DESCRIPTION
          if ((deal['description'] ?? "").isNotEmpty)
            Text(
              deal['description'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),

          const SizedBox(height: 10),

          /// 💰 TOTAL
          Text(
            "Total: ₹ ${deal['totalPrice'] ?? 0}",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          /// 📦 MILESTONES
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

          /// 🎯 ACTIONS
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
          SizedBox(height: 10),
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
    );
  }

  // show quckle diolage build
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
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
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
                final deal = {
                  "id": DateTime.now().millisecondsSinceEpoch.toString(),
                  "title": titleCtrl.text,
                  "price": priceCtrl.text,
                  "status": "pending",
                  "startDate": null,
                  "deadline": endDate?.toIso8601String(),
                  "type": "deal",
                };

                final docRef = FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .doc(); // create ID first

                await docRef.set({
                  "id": docRef.id, // 🔥 SAME ID
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

  // deal card options
  void _showDealOptions(BuildContext context, String receiverId) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
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

                  _showCreateDealDialog(context, receiverId);
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
                      const SnackBar(
                        content: Text(
                          "You already have an active/pending deal 🚫",
                        ),
                      ),
                    );
                    return;
                  }

                  _showPremiumDealDialog(context, receiverId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // void _showPremiumDealDialog(BuildContext context, String receiverId) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Premium deal coming soon 🚀")),
  //   );
  // }

  // deal option build

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
}

Widget dealCard(
  Map<String, dynamic> deal,
  String chatID,
  String currentUserId, // ✅ ADD THIS
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

  return Container(
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
        /// 🔥 HEADER
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

        /// 📄 TITLE
        Text(
          deal['title'],
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 6),

        /// 💰 PRICE
        Text(
          "₹ ${deal['price']}",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),

        const SizedBox(height: 10),

        /// 📅 DETAILS ROW
        Row(
          children: [
            Icon(Icons.calendar_today, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              start,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Icon(Icons.flag, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(end, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),

        const SizedBox(height: 14),
        if (status == "pending" && deal['senderId'] == currentUserId)
          const Text(
            "Waiting for response ⏳",
            style: TextStyle(color: Colors.grey),
          ),

        /// 🎯 ACTIONS
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
  );
}

Future<void> acceptDeal(String chatId, String dealId) async {
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(dealId)
      .update({
        "status": "active",
        "startDate": DateTime.now().toIso8601String(), // 🔥 AUTO START
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
