import 'package:voxa/feature/auth/data/model/user_model.dart';

class UserWithChat {
  final UserModel user;
  final int unreadCount;
  final String? lastSenderId;
  final String? lastMessage;

  UserWithChat({
    required this.user,
    this.unreadCount = 0,
    this.lastSenderId,
    this.lastMessage,
  });
}
