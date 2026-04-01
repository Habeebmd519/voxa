void main() {
  bool isExpanded = false;
  print(isExpanded ? 0.5 : 0);
  print((isExpanded ? 0.5 : 0).runtimeType);
  var x = isExpanded ? 0.5 : 0;
  takeDouble(x);
}

void takeDouble(double x) {
  print(x);
}
