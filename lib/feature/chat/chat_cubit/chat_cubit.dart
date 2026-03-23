import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  }) async {
    try {
      emit(ChatSending());

      await repository.sendMessage(
        chatId: chatId,
        receiverId: receiverId,
        text: text,
      );

      emit(ChatSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> markChatAsRead({
    required String chatId,
    required String receiverId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    await firestore.collection('users').doc(currentUserId).update({
      'unreadCount.$receiverId': 0,
    });
  }
}
