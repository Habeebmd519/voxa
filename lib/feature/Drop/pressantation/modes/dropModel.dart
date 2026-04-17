class DropModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;

  final String userAvatar;
  final String text;
  final DateTime createdAt;
  final int likeCount;

  /// ✅ ADD THIS
  final List<String> likedBy;

  DropModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.likedBy = const [], // ✅ default
  });
  DropModel copyWith({int? likeCount, List<String>? likedBy}) {
    return DropModel(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userAvatar: userAvatar,
      text: text,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
