import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:synapse/core/hive/pressentation/models/user_hive_model.dart';
import 'package:synapse/feature/user/bloc/UserState.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserLoading());

  final HiveServices hiveServices = HiveServices();

  void loadUsers() {
    final users = hiveServices.box.values.toList();

    if (users.isEmpty) {
      emit(UserEmpty());
    } else {
      emit(UserLoaded(users));
    }
  }

  // ✅ ADD THIS METHOD
  void listenUsers() {
    // ✅ FIRST: emit current data
    final users = hiveServices.box.values.toList();

    if (users.isEmpty) {
      emit(UserEmpty());
    } else {
      emit(UserLoaded(users));
    }

    // ✅ THEN: listen for changes
    hiveServices.box.listenable().addListener(() {
      final users = hiveServices.box.values.toList();

      if (users.isEmpty) {
        emit(UserEmpty());
      } else {
        emit(UserLoaded(users));
      }
    });
  }
}
