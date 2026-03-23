import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'sheet_state.dart';

class SheetCubit extends Cubit<SheetState> {
  SheetCubit() : super(ShowUsers()); // ✅ Initial state

  void openUsers() {
    emit(ShowUsers());
  }

  void openChat(UserModel user) {
    emit(ShowChat(user));
  }
}
