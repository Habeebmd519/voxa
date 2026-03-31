import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chat_sheet_controller.dart';
import 'package:voxa/feature/user/widget/chat_body.dart';

class DraggableChatSheet extends StatelessWidget {
  final UserModel user;

  const DraggableChatSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<ChatSheetController, double>(
      builder: (context, progress) {
        final minTop = screenHeight * 0.15;
        final maxTop = screenHeight * 0.85;

        final sheetTop = minTop + (maxTop - minTop) * progress;

        return Positioned(
          top: sheetTop,
          left: 0,
          right: 0,
          height: screenHeight - sheetTop,

          /// 🔥 ONLY POSITION CHANGES
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              final delta = details.primaryDelta! / screenHeight;

              final cubit = context.read<ChatSheetController>();

              double newValue = cubit.state + delta;
              newValue = newValue.clamp(0.0, 1.0);

              cubit.update(newValue);
            },

            child: _ChatSheetUI(user: user), // ✅ STATIC
          ),
        );
      },
    );
  }
}

class _ChatSheetUI extends StatelessWidget {
  final UserModel user;

  const _ChatSheetUI({required this.user});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // 🔥 IMPORTANT
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF4F8F1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ChatSheetBody(user: user), // ✅ NEVER rebuilds
            ),
          ],
        ),
      ),
    );
  }
}
