import 'package:synapse/feature/Drop/pressantation/modes/dropModel.dart';

abstract class TimelineState {}

class TimelineLoading extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final List<DropModel> drops;

  TimelineLoaded(this.drops);
}

class TimelineError extends TimelineState {}
