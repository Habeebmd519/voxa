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
    final senderId = currentUser.uid;
    final chatRef = firestore.collection('chats').doc(chatId);

    // 1. Prepare message data
    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // 2. Update the CHATS collection (for the specific conversation)
    final chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) {
      await chatRef.set({
        'participants': [senderId, receiverId],
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'unreadCount': {senderId: 0, receiverId: 1},
      });
    } else {
      await chatRef.update({
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'unreadCount.$receiverId': FieldValue.increment(1),
      });
    }

    // 3. Save the message in the sub-collection
    await chatRef.collection('messages').add(messageData);

    // --- 🔥 NEW: UPDATE THE USERS COLLECTION ---
    // This is what removes "Say hi 👋" from the home screen
    final batch = firestore.batch();

    final senderUserRef = firestore.collection('users').doc(senderId);
    final receiverUserRef = firestore.collection('users').doc(receiverId);

    final userUpdateData = {
      'lastMessage': text,
      'lastSenderId': senderId,
      'lastSeen': FieldValue.serverTimestamp(),
    };

    batch.update(senderUserRef, userUpdateData);
    batch.update(receiverUserRef, userUpdateData);

    // Update unread count inside the User document specifically
    batch.update(receiverUserRef, {
      'unreadCount.$senderId': FieldValue.increment(1),
    });

    await batch.commit();
    // --------------------------------------------

    // 4. Send Notification (Existing logic)
    final receiverDoc = await firestore
        .collection('users')
        .doc(receiverId)
        .get();
    final oneSignalId = receiverDoc.data()?['oneSignalId'];

    if (oneSignalId != null && oneSignalId.toString().isNotEmpty) {
      await NotificationHelper.sendPushNotification(
        playerId: oneSignalId,
        message: text,
        senderName: currentUser.email ?? "New message",
      );
    }
  }
}
