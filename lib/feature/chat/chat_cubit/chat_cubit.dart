import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/chat/Repositories/chat_repository/chat_repository.dart';
import 'chat_state.dart';

class ChatCubitt extends Cubit<ChatState> {
  final ChatRepository repository;

  ChatCubitt(this.repository) : super(ChatInitial());

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
}
