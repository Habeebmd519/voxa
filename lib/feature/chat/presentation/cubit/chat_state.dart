abstract class ChatState {}

class ChatClosed extends ChatState {}

class ChatOpened extends ChatState {
  final String receiverId;

  ChatOpened(this.receiverId);
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
