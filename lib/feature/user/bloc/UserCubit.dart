import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/user/bloc/UserState.dart';
import 'package:voxa/feature/user/service/UserRepository.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository repository;

  UserCubit(this.repository) : super(UserInitial());

  StreamSubscription? _sub;

  void listenUsers() {
    emit(UserLoading());

    _sub?.cancel();

    _sub = repository.getUsersStream().listen(
      (users) {
        if (users.isEmpty) {
          emit(UserEmpty());
        } else {
          emit(UserLoaded(users));
        }
      },
      onError: (e) {
        emit(UserError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
