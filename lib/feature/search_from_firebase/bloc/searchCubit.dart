import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/auth/data/model/user_model.dart';
import 'package:synapse/feature/search_from_firebase/bloc/searchState.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  Timer? _debounce;

  Future<List<UserModel>> _searchUsers(String query) async {
    final q = query.trim().toLowerCase();

    if (q.length < 2) return [];

    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('searchKeywords', arrayContains: q)
        .limit(20)
        .get();

    return result.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final q = value.trim();

      if (q.length < 2) {
        emit(SearchInitial());
        return;
      }

      emit(SearchLoading());

      try {
        final users = await _searchUsers(q);

        if (users.isEmpty) {
          emit(SearchEmpty());
        } else {
          emit(SearchSuccess(users));
        }
      } catch (e) {
        emit(SearchError());
      }
    });
  }

  void clear() {
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
