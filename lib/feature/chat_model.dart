class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final String date;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.date,
  });
}

final List<ChatItem> chatData = [
  ChatItem(
    name: "Ayaan",
    lastMessage: "Hey, are you coming today?",
    time: "10:45 AM",
    date: "Feb 7",
  ),
  ChatItem(
    name: "Sara",
    lastMessage: "Let’s catch up later",
    time: "9:30 AM",
    date: "Feb 6",
  ),
  ChatItem(
    name: "Rahul",
    lastMessage: "Sent you the files",
    time: "Yesterday",
    date: "Feb 5",
  ),
  ChatItem(
    name: "Nisha",
    lastMessage: "Okay 👍",
    time: "8:12 PM",
    date: "Feb 4",
  ),
  ChatItem(
    name: "Daniel",
    lastMessage: "Call me when free",
    time: "7:05 PM",
    date: "Feb 3",
  ),
];
