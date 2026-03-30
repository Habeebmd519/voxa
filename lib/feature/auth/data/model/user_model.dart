import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? photoUrl;

  //
  final String? oneSignalId;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? lastMessage;

  //
  final String? role;
  final String? place;
  final String? domain;
  final List<Map<String, dynamic>> projects;

  ////
  final Map<String, int> unreadCount; // key = otherUserId, value = unread count
  final String? lastSenderId;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.oneSignalId,
    this.isOnline = false,
    this.lastSeen,
    this.lastSenderId,
    this.lastMessage,
    this.unreadCount = const {},
    //
    this.role,
    this.place,
    this.domain,
    this.projects = const [],
  });

  /// FROM FIRESTORE
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],

      //
      oneSignalId: map['oneSignalId'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,

      lastSenderId: map['lastSenderId'],

      ///
      unreadCount: Map<String, int>.from(
        (map['unreadCount'] ?? {}).map(
          (key, value) => MapEntry(key, value as int),
        ),
      ),
      lastMessage: map['lastMessage'],
      //
      role: map['role'],
      place: map['place'],
      domain: map['domain'],
      projects: List<Map<String, dynamic>>.from(map['projects'] ?? []),

      //
    );
  }

  /// TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,

      //
      'oneSignalId': oneSignalId,
      'isOnline': isOnline,
      'lastSeen': lastSeen,

      //
      'unreadCount': unreadCount,
      'lastSenderId': lastSenderId,
      'lastMessage': lastMessage,
      //
      'role': role,
      'place': place,
      'domain': domain,
      'projects': projects,
    };
  }

  /// COPY WITH (very useful for updates)
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    String? oneSignalId,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, int>? unreadCount, // use nullable, not `= 0`
    String? lastSenderId,
    String? lastMessage,
    //
    String? role,
    String? place,
    String? domain,
    List<Map<String, dynamic>>? projects,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      oneSignalId: oneSignalId ?? this.oneSignalId,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      unreadCount: unreadCount ?? this.unreadCount,
      lastSenderId: lastSenderId ?? this.lastSenderId, // fixed
      lastMessage: lastMessage ?? this.lastMessage,
      //
      role: role ?? this.role,
      place: place ?? this.place,
      domain: domain ?? this.domain,
      projects: projects ?? this.projects,
    );
  }
}
