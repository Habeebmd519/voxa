abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List users;

  UserLoaded(this.users);
}

class UserEmpty extends UserState {}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}
