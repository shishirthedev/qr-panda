import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/counter_bloc.dart';
import '../../bloc/counter_state.dart';

class CounterDisplayNew extends StatelessWidget {
  const CounterDisplayNew({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Text(
          '${state.count}',
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
