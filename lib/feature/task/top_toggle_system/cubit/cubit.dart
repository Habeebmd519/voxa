import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/core/navigation/home_nav_controller.dart';
import 'package:synapse/feature/task/top_toggle_system/enum.dart';

class TopBarCubit extends Cubit<TopMode> {
  TopBarCubit() : super(TopMode.normal);

  void showSearch() => emit(TopMode.search);

  void showAdd() {
    emit(TopMode.add);
    HomeNavController.setIndex = 1;
    emit(TopMode.normal);
  }

  Future<void> closeAdd() async {
    emit(TopMode.closingAdd); // collapse field first

    await Future.delayed(const Duration(milliseconds: 250));

    emit(TopMode.normal); // bring back search + button
  }

  void reset() => emit(TopMode.normal);
}
