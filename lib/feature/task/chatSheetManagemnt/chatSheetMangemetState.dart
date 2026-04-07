enum Chatsheetmanage { half, zero }

class ChatsheetmanageState {
  final Chatsheetmanage selectedSheet;
  const ChatsheetmanageState({required this.selectedSheet});
  ChatsheetmanageState copyWith({Chatsheetmanage? selectedSheet}) {
    return ChatsheetmanageState(
      selectedSheet: selectedSheet ?? this.selectedSheet,
    );
  }
}
