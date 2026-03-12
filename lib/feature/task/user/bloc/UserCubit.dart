import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/task/user/bloc/UserState.dart';
import 'package:voxa/feature/task/user/service/UserRepository.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository repository;

  UserCubit(this.repository) : super(UserInitial());

  Future<void> loadUsers() async {
    emit(UserLoading());

    try {
      final users = await repository.getAllUsers();

      if (users.isEmpty) {
        emit(UserEmpty());
      } else {
        emit(UserLoaded(users));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
