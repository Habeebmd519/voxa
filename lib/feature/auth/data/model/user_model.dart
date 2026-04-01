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
  final String? exp;
  final String? domain;
  final List<Map<String, dynamic>> projects;

  ////
  final Map<String, int> unreadCount; // key = otherUserId, value = unread count
  final String? lastSenderId;

  // ⭐ Credibility
  final double rating;
  final int reviewCount;
  final int completedProjects;
  final List<String> badges;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isPro;

  // Availbilies
  final bool isAvailable;
  final String responseTime;
  final bool isRemote;
  // skill
  final List<String> skills;

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
    this.exp,
    this.domain,
    this.projects = const [],
    // ⭐ Credibility
    this.rating = 0.0,
    this.reviewCount = 0,
    this.completedProjects = 0,
    this.badges = const [],
    this.isEmailVerified = true,
    this.isPhoneVerified = true,
    this.isPro = false,
    // Availbilies
    this.isAvailable = true,
    this.responseTime = "Fast",
    this.isRemote = true,

    //skill
    this.skills = const [],
  });

  /// FROM FIRESTORE
  factory UserModel.fromMap(Map<String, dynamic> map) {
    print("🔥 RAW USER MAP: $map");
    print("🔥 RATING FIELD: ${map['rating']} (${map['rating']?.runtimeType})");
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
      exp: map['exp'],
      domain: map['domain'],
      projects: List<Map<String, dynamic>>.from(map['projects'] ?? []),

      // ⭐ Credibility
      rating: (map['rating'] ?? 0.0)
          .toDouble(), // 1. Handle Null with ?? 2. Force double
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      completedProjects: map['completedProjects'] is int
          ? map['completedProjects']
          : 0,
      badges: List<String>.from(map['badges'] ?? []),
      isEmailVerified: map['isEmailVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      isPro: map['isPro'] ?? false,
      // Availbilies
      isAvailable: map['isAvailable'] ?? true,
      responseTime: map['responseTime'] ?? "Fast",
      isRemote: map['isRemote'] ?? true,
      // skill
      skills: List<String>.from(map['skills'] ?? []),
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
      'exp': exp,
      'domain': domain,
      'projects': projects,
      // ⭐ Credibility
      'rating': rating,
      'reviewCount': reviewCount,
      'completedProjects': completedProjects,
      'badges': badges,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isPro': isPro,
      // Availbilies
      'isAvailable': isAvailable,
      'responseTime': responseTime,
      'isRemote': isRemote,
      // skill
      'skills': skills,
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
    String? exp,
    String? domain,
    List<Map<String, dynamic>>? projects,
    // ⭐ Credibility
    double? rating,
    int? reviewCount,
    int? completedProjects,
    List<String>? badges,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isPro,
    // availbilities
    bool? isAvailable,
    String? responseTime,
    bool? isRemote,
    //skill
    List<String>? skills,
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
      exp: exp ?? this.exp,
      domain: domain ?? this.domain,
      projects: projects ?? this.projects,
      // ⭐ Credibility
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedProjects: completedProjects ?? this.completedProjects,
      badges: badges ?? this.badges,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isPro: isPro ?? this.isPro,
      // availbilities
      isAvailable: isAvailable ?? this.isAvailable,
      responseTime: responseTime ?? this.responseTime,
      isRemote: isRemote ?? this.isRemote,

      ///
      skills: skills ?? this.skills,
    );
  }
}
