import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

class CurrentUserCubit extends Cubit<UserModel?> {
  CurrentUserCubit() : super(null);

  void loadCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
            if (doc.exists) {
              emit(UserModel.fromMap(doc.data()!));
            }
          });
    }
  }
}
