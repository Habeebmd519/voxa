import 'package:flutter/material.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';

class ChatProfileBackground extends StatelessWidget {
  final UserModel user;

  const ChatProfileBackground({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB5D96A), // your green
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// 🔥 PROFILE IMAGE
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? Text(user.name[0])
                  : null,
            ),

            const SizedBox(height: 12),

            /// NAME
            Text(
              user.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            /// ONLINE STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(radius: 4, backgroundColor: Colors.green),
                SizedBox(width: 6),
                Text("Online"),
              ],
            ),

            const SizedBox(height: 20),

            /// OPTIONAL → domain / role
            if (user.domain != null && user.domain!.isNotEmpty)
              Text(user.domain!),
          ],
        ),
      ),
    );
  }
}
