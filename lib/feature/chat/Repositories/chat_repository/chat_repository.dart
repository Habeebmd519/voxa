import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voxa/core/network/notfication_helper/notfication_helper.dart';

class ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepository({required this.firestore});

  // voxa/feature/chat/Repositories/chat_repository/chat_repository.dart

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final senderId = currentUser.uid;
    final chatRef = firestore.collection('chats').doc(chatId);

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // Keep this: updates the conversation metadata
    await chatRef.set({
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));

    // Keep this: adds the actual message
    await chatRef.collection('messages').add(messageData);

    // ❌ REMOVE the batch update to the 'users' collection here
    // because you are doing it in the Cubit now.

    // --------------------------------------------
  }
}
