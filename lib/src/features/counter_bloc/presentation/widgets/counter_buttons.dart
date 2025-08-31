import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/counter_bloc.dart';
import '../../bloc/counter_event.dart';

class CounterButtonsNew extends StatelessWidget {
  const CounterButtonsNew({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CounterBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => bloc.add(DecrementEvent()),
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => bloc.add(IncrementEvent()),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
