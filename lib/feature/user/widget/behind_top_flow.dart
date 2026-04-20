import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:synapse/feature/auth/data/model/user_model.dart';
import 'package:synapse/feature/user/widget/behind_top_swction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/user/bloc/current_user_cubit.dart';

class BehindTopFlow extends StatelessWidget {
  UserModel user;
  BehindTopFlow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        UserModel fullUser = user;
        if (snapshot.hasData && snapshot.data?.data() != null) {
          try {
            fullUser = UserModel.fromMap(
              snapshot.data!.data() as Map<String, dynamic>,
            );
          } catch (e) {
            debugPrint("Error parsing full user: $e");
          }
        }
        final actualCurrentUser = context.watch<CurrentUserCubit>().state;
        
        return buildProfieAvatr(
            user: fullUser, 
            currentUser: actualCurrentUser ?? fullUser,
        );
      },
    );
  }
}
