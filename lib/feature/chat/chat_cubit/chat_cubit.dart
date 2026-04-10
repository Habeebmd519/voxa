import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/core/hive/pressentation/models/user_hive_model.dart';
import 'package:voxa/core/network/notfication_helper/notfication_helper.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/chat/Repositories/chat_repository/chat_repository.dart';
import 'chat_state.dart';

class ChatCubitt extends Cubit<ChatState> {
  final ChatRepository repository;
  final FirebaseFirestore firestore;

  ChatCubitt({required this.repository, required this.firestore})
    : super(ChatInitial());

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
    required String currentUserId,
  }) async {
    try {
      // 1. We don't wait for 'ChatSending' to update Firestore.
      // We want this to be a "Fire and Forget" operation for speed.

      final batch = firestore.batch();
      final msgRef = firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      final senderRef = firestore.collection('users').doc(currentUserId);
      final receiverRef = firestore.collection('users').doc(receiverId);

      // Save Message
      batch.set(msgRef, {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update Receiver (Increment unread)
      batch.update(receiverRef, {
        'unreadCount.$currentUserId': FieldValue.increment(1),
        'lastMessage': text,
        'lastSenderId': currentUserId,
      });

      // Update Sender (Sync last message)
      batch.update(senderRef, {
        'lastMessage': text,
        'lastSenderId': currentUserId,
      });

      // Execute everything in ONE network request
      await batch.commit();
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      final oneSignalId = receiverDoc.data()?['oneSignalId'];

      if (oneSignalId != null && oneSignalId.toString().isNotEmpty) {
        await NotificationHelper.sendPushNotification(
          playerId: oneSignalId,
          message: text,
          senderName: FirebaseAuth.instance.currentUser?.email ?? "New message",
        );
      }

      // 2. Since we handled the Firestore logic here,
      // check your Repository. If repository.sendMessage
      // ALSO updates counts, you MUST remove that code from the repository.

      emit(ChatSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void handleIncomingMessage(Map<String, dynamic> data) async {
    final senderId = data['senderId'];
    final text = data['text'] ?? '';

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();

    final sender = UserModel.fromMap(doc.data()!);

    final hive = HiveServices();
    await hive.saveOrUpdateUser(sender, text);
    await hive.incrementUnread(sender.uid);
  }

  Future<void> markChatAsRead({
    required String chatId,
    required String receiverId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // Clears the badge for the logged-in user
    await firestore.collection('users').doc(currentUserId).update({
      'unreadCount.$receiverId': 0,
    });
  }
}
