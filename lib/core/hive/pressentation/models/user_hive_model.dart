import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 0)
class UserHiveModel {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? photoUrl;

  @HiveField(3)
  final String? lastMessage;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final DateTime? lastMessageTime;

  @HiveField(6)
  final int unreadCount; // ✅ ADD THIS

  UserHiveModel({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.lastMessage,
    this.email,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// ✅ FIXED copyWith
  UserHiveModel copyWith({
    String? uid,
    String? name,
    String? photoUrl,
    String? lastMessage,
    String? email,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return UserHiveModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      email: email ?? this.email,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// ✅ FIXED toHive
  static UserHiveModel toHive(UserModel user) {
    return UserHiveModel(
      uid: user.uid,
      name: user.name,
      photoUrl: user.photoUrl,
      email: user.email,
      unreadCount: 0,
    );
  }

  UserModel toUserModel() {
    return UserModel(
      uid: uid,
      email: email ?? '',
      name: name,
      phone: '',
      photoUrl: photoUrl,
      lastMessage: lastMessage,
    );
  }
}

class HiveServices {
  Box<UserHiveModel> get box {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final boxName = 'users_$uid';

    if (!Hive.isBoxOpen(boxName)) {
      throw Exception("⚠️ Box $boxName not opened yet");
    }

    return Hive.box<UserHiveModel>(boxName);
  }

  Future<void> saveOrUpdateUser(UserModel user, String message) async {
    final exists = box.containsKey(user.uid);

    if (!exists) {
      box.put(
        user.uid,
        UserHiveModel.toHive(user).copyWith(lastMessage: message),
      );
    } else {
      final oldUser = box.get(user.uid)!;

      box.put(user.uid, oldUser.copyWith(lastMessage: message));
    }
  }

  Future<void> incrementUnread(String uid) async {
    final user = box.get(uid);
    if (user == null) return;

    box.put(uid, user.copyWith(unreadCount: user.unreadCount + 1));
  }

  Future<void> clearUnread(String uid) async {
    final user = box.get(uid);
    if (user == null) return;

    box.put(uid, user.copyWith(unreadCount: 0));
  }
}
