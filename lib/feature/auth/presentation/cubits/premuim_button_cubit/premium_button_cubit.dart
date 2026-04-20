import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/auth/presentation/cubits/premuim_button_cubit/premium_button_state.dart';

class PremiumButtonCubit extends Cubit<PremiumButtonState> {
  PremiumButtonCubit()
    : super(PremiumButtonState(isLoading: false, isPressed: false));
  void pressDown() => emit(state.copyWith(isPressed: true));
  void pressUp() => emit(state.copyWith(isPressed: false));

  void startLoading() {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));
  }

  void stopLoading() {
    if (!state.isLoading) return;
    emit(state.copyWith(isLoading: false));
  }
}
