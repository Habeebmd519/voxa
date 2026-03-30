import 'package:voxa/feature/auth/data/model/user_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// class ProfileLoaded extends ProfileState {
//   final String name;
//   final String email;
//   final String? photoUrl;

//   const ProfileLoaded({required this.name, required this.email, this.photoUrl});
// }
class ProfileLoaded extends ProfileState {
  final UserModel user;

  const ProfileLoaded({required this.user});
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
