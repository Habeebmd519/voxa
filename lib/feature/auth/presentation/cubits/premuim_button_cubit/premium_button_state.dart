class PremiumButtonState {
  final bool isLoading;
  final bool isPressed;
  PremiumButtonState({required this.isLoading, required this.isPressed});

  PremiumButtonState copyWith({bool? isPressed, bool? isLoading}) {
    return PremiumButtonState(
      isLoading: isLoading ?? this.isLoading,
      isPressed: isPressed ?? this.isPressed,
    );
  }
}
