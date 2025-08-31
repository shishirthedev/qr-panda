import 'package:flutter/material.dart';

class CounterDisplay extends StatelessWidget {
  final int count;

  const CounterDisplay({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent.shade700,
          ),
        ),
      ),
    );
  }
}
