abstract class SheetState {}

class ShowUsers extends SheetState {}

class ShowChat extends SheetState {
  final dynamic user; // we will replace with UserModel

  ShowChat(this.user);
}
