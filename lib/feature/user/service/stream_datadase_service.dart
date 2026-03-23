import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

class databaseService {
  Stream<List<UserModel>> getUsersStream() {
    final String? currentId = FirebaseAuth.instance.currentUser?.uid;

    // If no user is logged in, return an empty stream immediately
    if (currentId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        // Optional: Filter out the current user so they don't see themselves in the list
        .where('uid', isNotEqualTo: currentId)
        // Optional: Order by the time of the last message
        // Note: This requires a Firestore Index if you use 'where' and 'orderBy' together
        // .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserModel.fromMap(doc.data());
          }).toList();
        });
  }
}
