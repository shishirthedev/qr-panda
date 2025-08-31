import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickqr/src/features/counter/widgets/counter_button.dart';
import 'counter_view_model.dart';
import 'widgets/counter_display.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterVM = context.watch<CounterViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 30),
            CounterDisplay(count: counterVM.count),
            const SizedBox(height: 50),
            CounterButtons(
              onIncrement: counterVM.increment,
              onDecrement: counterVM.decrement,
            ),
          ],
        ),
      ),
    );
  }
}
