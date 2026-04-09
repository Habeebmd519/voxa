import 'package:voxa/feature/auth/data/model/user_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<UserModel> users;
  SearchSuccess(this.users);
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {}
