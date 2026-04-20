import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:synapse/feature/auth/data/model/user_model.dart';

class UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  UserRepository({required this.firestore, required this.auth});
  Stream<List<UserModel>> getUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
    });
  }
  // /// Get users as a Stream for real-time "Last Message" updates
  // Stream<List<UserModel>> getUsersStream() {
  //   final currentUid = auth.currentUser?.uid;

  //   if (currentUid == null) return Stream.value([]);

  //   return firestore.collection('users').snapshots().map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => UserModel.fromMap(doc.data()))
  //         .where((user) => user.uid != currentUid)
  //         .toList();
  //   });
  // }

  /// Original Future method (Fixed with null check)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return [];

      final snapshot = await firestore.collection('users').get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.uid != currentUid)
          .toList();
    } catch (e) {
      print("🔥 FIRESTORE ERROR: $e");
      throw Exception('Failed to load users: $e');
    }
  }
}
