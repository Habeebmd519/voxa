void main() {
  bool isExpanded = false;
  print(isExpanded ? 0.5 : 0);
  print((isExpanded ? 0.5 : 0).runtimeType);
  num x = 5; // This is technically an int
  takeDouble(x.toDouble()); // Converts 5 to 5.0
}

void takeDouble(double x) {
  print(x);
}
