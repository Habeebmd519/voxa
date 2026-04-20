// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:synapse/feature/task/top_toggle_system/bloc/event.dart';
// import 'package:synapse/feature/task/top_toggle_system/bloc/state.dart';

// class TopToggleCubit extends Bloc<TopToggleEvent, TopToggleState> {
//   TopToggleCubit() : super(LocalSeachToggle(isOn: true, isSrchOn: false)) {
//     on<Localopen>((event, emit) {
//       if (state is LocalSeachToggle) {
//         final current = state as LocalSeachToggle;
//         emit(current.copyWith(isOn: true, isSrchOn: false));
//       }
//     });
//     on<Localclose>((event, emit) {
//       if (state is LocalSeachToggle) {
//         final current = state as LocalSeachToggle;
//         emit(current.copyWith(isOn: false, isSrchOn: false));
//       }
//     });
//     on<LocalSrhOn>((event, emit) {
//       if (state is LocalSeachToggle) {
//         final current = state as LocalSeachToggle;
//         emit(current.copyWith(isOn: true, isSrchOn: true));
//       }
//     });
//     on<Globalopen>((event, emit) {
//       emit(GlobalSeachToggle(isOn: true));
//     });
//     on<Globalclose>((event, emit) {
//       emit(LocalSeachToggle(isOn: true, isSrchOn: false));
//     });
//   }
// }
