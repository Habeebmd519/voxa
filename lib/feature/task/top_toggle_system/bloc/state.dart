abstract class TopToggleState {}

class LocalSeachToggle extends TopToggleState {
  final bool isOn;
  final bool isSrchOn;
  LocalSeachToggle({required this.isOn, required this.isSrchOn});
  LocalSeachToggle copyWith({bool? isOn, bool? isSrchOn}) {
    return LocalSeachToggle(
      isOn: isOn ?? this.isOn,
      isSrchOn: isSrchOn ?? this.isSrchOn,
    );
  }
}

class GlobalSeachToggle extends TopToggleState {
  final bool isOn;
  GlobalSeachToggle({this.isOn = false});
  GlobalSeachToggle copyWith({bool? isOn}) {
    return GlobalSeachToggle(isOn: this.isOn);
  }
}
