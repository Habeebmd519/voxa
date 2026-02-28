import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/feature/task/top_toggle_system/enum.dart';

class TopBarCubit extends Cubit<TopMode> {
  TopBarCubit() : super(TopMode.normal);

  void showSearch() => emit(TopMode.search);

  Future<void> showAdd() async {
    emit(TopMode.addPreparing);

    await Future.delayed(const Duration(milliseconds: 250));

    emit(TopMode.add);
  }

  Future<void> closeAdd() async {
    emit(TopMode.closingAdd); // collapse field first

    await Future.delayed(const Duration(milliseconds: 250));

    emit(TopMode.normal); // bring back search + button
  }

  void reset() => emit(TopMode.normal);
}
