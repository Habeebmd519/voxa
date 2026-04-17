import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/Drop/pressantation/bloc/friendCubit/freindState.dart';
import 'package:voxa/feature/user/bloc/current_user_cubit.dart';

class FriendCubit extends Cubit<FriendState> {
  FriendCubit() : super(FriendInitial());

  final _firestore = FirebaseFirestore.instance;
  Future<void> toggleFriend({
    required String myId,
    required String targetUserId,
    required BuildContext context,
  }) async {
    if (targetUserId.isEmpty) return;

    final currentUser = context.read<CurrentUserCubit>().state;

    if (currentUser == null) return;

    final currentFriends = List<String>.from(currentUser.friendIds ?? []);

    final isFriend = currentFriends.contains(targetUserId);

    /// 🔥 1. UPDATE UI INSTANTLY (OPTIMISTIC)
    if (isFriend) {
      currentFriends.remove(targetUserId);
    } else {
      currentFriends.add(targetUserId);
    }

    /// 🔥 Emit instantly (NO WAIT)
    context.read<CurrentUserCubit>().emitUpdatedFriends(currentFriends);

    try {
      final myRef = _firestore.collection('users').doc(myId);
      final otherRef = _firestore.collection('users').doc(targetUserId);

      await _firestore.runTransaction((tx) async {
        if (isFriend) {
          tx.set(myRef, {
            'friendIds': FieldValue.arrayRemove([targetUserId]),
          }, SetOptions(merge: true));

          tx.set(otherRef, {
            'friendIds': FieldValue.arrayRemove([myId]),
          }, SetOptions(merge: true));
        } else {
          tx.set(myRef, {
            'friendIds': FieldValue.arrayUnion([targetUserId]),
          }, SetOptions(merge: true));

          tx.set(otherRef, {
            'friendIds': FieldValue.arrayUnion([myId]),
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      print("ERROR: $e");

      /// 🔁 OPTIONAL: rollback if failed
      context.read<CurrentUserCubit>().loadCurrentUser();
    }
  }
}
