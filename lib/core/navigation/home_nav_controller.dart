import 'package:flutter/material.dart';

class HomeNavController {
  static final ValueNotifier<int> _index = ValueNotifier(0);

  // Getter
  static ValueNotifier<int> get index => _index;

  // Setter
  static set setIndex(int newIndex) {
    _index.value = newIndex;
  }
}
