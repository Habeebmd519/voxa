import 'package:voxa/blocs/buttonAnm_bloc/button_state.dart';

abstract class ButtonEvent {}

class AuthButtonPressed extends ButtonEvent {
  final AuthButton button;
  AuthButtonPressed(this.button);
}
