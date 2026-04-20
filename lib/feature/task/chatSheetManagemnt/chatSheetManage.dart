import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';

class ChatsheetmanageCubit extends Cubit<ChatsheetmanageState> {
  ChatsheetmanageCubit()
    : super(ChatsheetmanageState(selectedSheet: Chatsheetmanage.half));

  void changeSheet(Chatsheetmanage sheet) {
    emit(state.copyWith(selectedSheet: sheet));
  }
}
