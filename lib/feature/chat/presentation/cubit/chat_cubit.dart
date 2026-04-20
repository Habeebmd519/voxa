import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:synapse/feature/chat/data/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  // final chat_repository repository;

  ChatCubit() : super(ChatClosed());

  void openChat(String receiverId) {
    emit(ChatOpened(receiverId));
  }

  void closeChat() {
    emit(ChatClosed());
  }

  // Future<void> sendMessage({
  //   required String receiverId,
  //   required String text,
  // }) async {
  //   try {
  //     await repository.sendMessage(receiverId: receiverId, text: text);
  //   } catch (e) {
  //     emit(ChatError("Failed to send message"));
  //   }
  // }
}
