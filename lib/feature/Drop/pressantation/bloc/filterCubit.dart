import 'package:flutter_bloc/flutter_bloc.dart';

// filter_cubit.dart
enum DropFilter { all, friends, mine }

extension DropFilterX on DropFilter {
  String get label {
    switch (this) {
      case DropFilter.all:
        return "All Drops";
      case DropFilter.friends:
        return "Friends Drops";
      case DropFilter.mine:
        return "My Drops";
    }
  }
}

class FilterCubit extends Cubit<String> {
  FilterCubit() : super("All Drops");

  void changeFilter(String filter) => emit(filter);
}
