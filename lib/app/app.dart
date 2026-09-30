import 'package:flutter/material.dart';
import 'package:remora/screens/rides_screen.dart';

class RemoraApp extends StatelessWidget {
  const RemoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remora',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const RidesScreen(title: "Rides"),
    );
  }
}
