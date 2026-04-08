import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/task/bottomSheet/cubit/sheet_cubit.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetManage.dart';
import 'package:voxa/feature/task/chatSheetManagemnt/chatSheetMangemetState.dart';

class BouncingArrow extends StatefulWidget {
  const BouncingArrow({super.key});

  @override
  State<BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<BouncingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SheetCubit>().openUsers();
        context.read<ChatsheetmanageCubit>().changeSheet(Chatsheetmanage.half);
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: child,
          );
        },
        child: CircleAvatar(
          backgroundColor: Color.fromARGB(255, 79, 127, 47),
          child: const Icon(
            Icons.keyboard_arrow_up,
            size: 40,
            color: Color.fromARGB(255, 175, 218, 111),
          ),
        ),
      ),
    );
  }
}
