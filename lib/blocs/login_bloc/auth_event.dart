abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted(this.email, this.password);
}

class SignUpSubmitted extends AuthEvent {
  final String email;
  final String password;
  SignUpSubmitted(this.email, this.password);
}
