import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:synapse/feature/Drop/pressantation/modes/dropModel.dart';

class DropSarvice {
  Future<void> toggleFriend(String targetUserId) async {
    final myId = FirebaseAuth.instance.currentUser!.uid;

    if (targetUserId.isEmpty) return; // safety

    final myRef = FirebaseFirestore.instance.collection('users').doc(myId);

    final otherRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final myDoc = await tx.get(myRef);
      final myFriends = List.from(myDoc['friendIds'] ?? []);

      final isFriend = myFriends.contains(targetUserId);

      if (isFriend) {
        /// ❌ UNFRIEND (remove both sides)
        tx.update(myRef, {
          'friendIds': FieldValue.arrayRemove([targetUserId]),
        });

        tx.update(otherRef, {
          'friendIds': FieldValue.arrayRemove([myId]),
        });
      } else {
        /// ✅ INFRIEND (add both sides)
        tx.update(myRef, {
          'friendIds': FieldValue.arrayUnion([targetUserId]),
        });

        tx.update(otherRef, {
          'friendIds': FieldValue.arrayUnion([myId]),
        });
      }
    });
  }
}
