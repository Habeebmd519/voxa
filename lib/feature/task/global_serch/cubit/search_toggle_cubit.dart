import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchToggleCubit extends Cubit<bool> {
  SearchToggleCubit() : super(false);
  void setTrue() {
    if (!state) emit(true); // only emit if state is not already true
  }

  void setFalse() {
    if (state) emit(false); // only emit if state is not already false
  }
}
