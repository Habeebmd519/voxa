class TermsState {
  final bool accepted;

  const TermsState({this.accepted = false});

  TermsState copyWith({bool? accepted}) {
    return TermsState(accepted: accepted ?? this.accepted);
  }
}
