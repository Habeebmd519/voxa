import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/blocs/buttonAnm_bloc/button_event.dart';
import 'package:voxa/blocs/buttonAnm_bloc/button_state.dart';

class ButtonBloc extends Bloc<ButtonEvent, ButtonState> {
  ButtonBloc()
    : super(
        const ButtonState(selectedButton: AuthButton.login, isVisible: true),
      ) {
    on<AuthButtonPressed>((event, emit) async {
      // Hide first (for animation reset)
      emit(state.copyWith(isVisible: false, selectedButton: event.button));

      await Future.delayed(const Duration(milliseconds: 30));

      emit(state.copyWith(isVisible: true));
    });
  }
}
