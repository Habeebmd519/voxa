import 'package:flutter_bloc/flutter_bloc.dart';

class ToggleCubit extends Cubit<bool> {
  ToggleCubit() : super(false); // default value = false

  void setTrue() {
    if (!state) emit(true); // only emit if state is not already true
  }

  void setFalse() {
    if (state) emit(false); // only emit if state is not already false
  }
}
