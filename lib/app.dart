import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:quickqr/src/core/app_theme.dart';
import 'package:quickqr/src/features/counter/counter_page.dart';
import 'package:quickqr/src/features/counter/counter_view_model.dart';
import 'package:quickqr/src/features/counter_bloc/bloc/counter_bloc.dart';
import 'package:quickqr/src/features/home/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterViewModel(),
      child: MaterialApp(
        title: 'Provider Counter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const CounterPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const HomePage(),
      ),
    );
  }
}
