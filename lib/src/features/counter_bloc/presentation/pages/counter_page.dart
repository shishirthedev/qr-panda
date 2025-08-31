import 'package:flutter/material.dart';
import '../widgets/counter_buttons.dart';
import '../widgets/counter_display.dart';

class CounterPageNew extends StatelessWidget {

  const CounterPageNew({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CounterDisplayNew(),
            SizedBox(height: 50),
            CounterButtonsNew(),
          ],
        ),
      ),
    );
  }
}
