import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voxa/feature/task/user/model/user_model.dart';

class UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  UserRepository({required this.firestore, required this.auth});

  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUid = auth.currentUser!.uid;

      final snapshot = await firestore.collection('users').get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.uid != currentUid) // exclude self
          .toList();

      return users;
    } catch (e) {
      print("🔥 FIRESTORE ERROR: $e");
      throw Exception('Failed to load users');
      // rethrow;
    }
  }
}
