import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/blocs/checkBoxBoc/check_event.dart';
import 'package:voxa/blocs/checkBoxBoc/check_state.dart';

class TermsBloc extends Bloc<TermsEvent, TermsState> {
  TermsBloc() : super(const TermsState()) {
    on<TermsToggled>((event, emit) {
      emit(state.copyWith(accepted: !state.accepted));
    });
  }
}
