import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voxa/core/network/notfication_helper/notfication_helper.dart';

class ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepository({required this.firestore});

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    final chatRef = firestore.collection('chats').doc(chatId);

    final messageData = {
      'senderId': currentUser.uid,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    final chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      await chatRef.set({
        'participants': [currentUser.uid, receiverId],
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'lastSenderId': currentUser.uid,
        'unreadCount': 1, // first message
      });
    } else {
      await chatRef.update({
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'lastSenderId': currentUser.uid,
        'unreadCount': FieldValue.increment(1),
      });
    }

    // Save message
    await chatRef.collection('messages').add(messageData);

    // 🔔 Notification (already correct)
    final receiverDoc = await firestore
        .collection('users')
        .doc(receiverId)
        .get();

    final oneSignalId = receiverDoc.data()?['oneSignalId'];

    if (oneSignalId != null) {
      await NotificationHelper.sendPushNotification(
        playerId: oneSignalId,
        message: text,
        senderName: currentUser.email ?? "New message",
      );
    }
  }
}
