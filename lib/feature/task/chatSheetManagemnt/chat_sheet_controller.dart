import 'package:flutter_bloc/flutter_bloc.dart';

class ChatSheetController extends Cubit<double> {
  ChatSheetController() : super(0.0);

  void update(double value) {
    emit(value.clamp(0.0, 1.0));
  }
}
