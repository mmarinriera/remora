import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remora/app/app_state.dart';

class RidesScreen extends StatelessWidget {
  final String title;
  const RidesScreen({super.key, required this.title});

  String _formatDate(DateTime date) {
    return DateFormat.yMMMEd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final rides = context.watch<AppState>().rides;
    print('nrides: ${rides.length}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: rides.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            color: Color.fromARGB(255, 0, 124, 155),
            child: Center(
              child: Text(
                'Start: ${_formatDate(rides[index].startedAt)}\nDuration: ?\nDistance: ${rides[index].totalDistance}',
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: 1.0,
            width: double.infinity,
            child: ColoredBox(color: Color(0xFF000000)),
          );
        },
      ),
    );
  }
}
