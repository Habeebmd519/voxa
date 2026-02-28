enum AuthButton { info, login, signup }

class ButtonState {
  final AuthButton selectedButton;
  final bool isVisible;

  const ButtonState({required this.selectedButton, required this.isVisible});

  ButtonState copyWith({AuthButton? selectedButton, bool? isVisible}) {
    return ButtonState(
      selectedButton: selectedButton ?? this.selectedButton,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
