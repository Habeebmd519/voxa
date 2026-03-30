import 'package:flutter_bloc/flutter_bloc.dart';

class EditCubit extends Cubit<bool> {
  EditCubit() : super(false);

  void toggle() => emit(!state);

  void enable() => emit(true);

  void disable() => emit(false);
}
