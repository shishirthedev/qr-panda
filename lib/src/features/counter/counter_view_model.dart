import 'package:flutter/material.dart';

class CounterViewModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // notify UI to rebuild
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}
