abstract class FriendState {}

class FriendInitial extends FriendState {}

class FriendLoading extends FriendState {}

class FriendUpdated extends FriendState {
  final List<String> friendIds;

  FriendUpdated(this.friendIds);
}

class FriendError extends FriendState {
  final String message;

  FriendError(this.message);
}
