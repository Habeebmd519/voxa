import 'package:hive/hive.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 0)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? photoUrl;

  @HiveField(3)
  String? lastMessage;

  @HiveField(4)
  int unreadCount;

  UserHiveModel({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.lastMessage,
    this.unreadCount = 0,
  });
}

final box = Hive.box<UserHiveModel>('users');

UserHiveModel toHive(UserModel user) {
  return UserHiveModel(
    uid: user.uid,
    name: user.name,
    photoUrl: user.photoUrl,
    lastMessage: user.lastMessage,
    unreadCount: 0,
  );
}

class HiveServices {
  Future<void> saveOrUpdateUser(UserModel user, String message) async {
    final box = Hive.box<UserHiveModel>('users');

    final exists = box.containsKey(user.uid);

    if (!exists) {
      // 🔥 FIRST TIME CHAT
      final newUser = UserHiveModel(
        uid: user.uid,
        name: user.name,
        photoUrl: user.photoUrl,
        lastMessage: message,
        unreadCount: 0,
      );

      box.put(user.uid, newUser);
    } else {
      // 🔄 UPDATE EXISTING CHAT
      final oldUser = box.get(user.uid)!;

      final updatedUser = UserHiveModel(
        uid: oldUser.uid,
        name: oldUser.name,
        photoUrl: oldUser.photoUrl,
        lastMessage: message,
        unreadCount: oldUser.unreadCount,
      );

      box.put(user.uid, updatedUser);
    }
  }
}
