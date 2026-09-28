import 'package:flutter/material.dart';
import 'package:remora/database/database.dart';
import 'package:remora/models/ride.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:remora/models/track_point.dart';

import 'dart:async';

import 'ride_tracker.dart';
import 'services/location_service.dart';
import 'repositories/ride_repository.dart';
import 'ride_map.dart';

void main() {
  runApp(const RemoraApp());
}

class RemoraApp extends StatelessWidget {
  const RemoraApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remora',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const MainPage(title: 'Remora'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime;
  late String _elapsedTimeString;
  late Timer timer;
  final RideTracker _rideTracker = RideTracker(
    LocationService(),
    SqliteRideRepository(AppDatabase()),
  );
  late List<Ride> _ridesList = [];

  @override
  void initState() {
    super.initState();

    _elapsedTime = Duration.zero;
    _elapsedTimeString = _formatElapsedTime(_elapsedTime);

    // Create a timer that runs a callback every 100 milliseconds to update UI
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        // Update elapsed time only if the stopwatch is running
        if (_stopwatch.isRunning) {
          _updateElapsedTime();
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRides();
      initializeDateFormatting('de_DE', null);
    });
  }

  Future<void> _updateRides() async {
    _ridesList = await _rideTracker.getRides();
  }

  // Update elapsed time and formatted time string
  void _updateElapsedTime() {
    setState(() {
      _elapsedTime = _stopwatch.elapsed;
      _elapsedTimeString = _formatElapsedTime(_elapsedTime);
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMEd().add_jm().format(date);
  }

  // Format a Duration into a string (MM:SS.SS)
  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  Future<void> _startTrack() async {
    await _rideTracker.startTrack();
    setState(() {
      _stopwatch.start();
    });
  }

  Future<void> _stopTrack() async {
    await _rideTracker.stopTrack();
    await _updateRides();
    setState(() {
      _stopwatch.stop();
    });
  }

  @override
  void dispose() {
    _rideTracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('Track time:'),
            Text(
              _elapsedTimeString,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FilledButton(
              onPressed: !_rideTracker.trackActive ? _startTrack : null,
              child: const Text('Start Track'),
            ),
            FilledButton(
              onPressed: _rideTracker.trackActive ? _stopTrack : null,
              child: const Text('Stop Track'),
            ),
            const Text('Current position:'),
            Text(
              'Latitude: ${_rideTracker.currentPosition?.latitude ?? '-'}\n'
              'Longitude: ${_rideTracker.currentPosition?.longitude ?? '-'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Text('Current ride:'),
            Text(
              'Started: ${_rideTracker.currentRideStart ?? '-'}\n'
              'Distance: ${_rideTracker.currentRideDistance ?? '-'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text("Past rides: ${_ridesList.length}", textAlign: TextAlign.left),
            SizedBox(
              height: 300,
              child: RideMap(
                points: [
                  TrackPoint(
                    timestamp: DateTime.now(),
                    latitude: 48.137,
                    longitude: 11.575,
                  ),
                  TrackPoint(
                    timestamp: DateTime.now(),
                    latitude: 48.138,
                    longitude: 11.574,
                  ),
                  TrackPoint(
                    timestamp: DateTime.now(),
                    latitude: 48.139,
                    longitude: 11.572,
                  ),
                  TrackPoint(
                    timestamp: DateTime.now(),
                    latitude: 48.142,
                    longitude: 11.571,
                  ),
                ],
              ),
            ),

            // SizedBox(
            //   height: 300,
            //   child: ListView(
            //     padding: const EdgeInsets.all(8),
            //     children: [
            //       for (Ride ride in _ridesList)
            //         Container(
            //           height: 50,
            //           color: Colors.amber[600],
            //           child: Center(
            //             child: Text(
            //               'Ride from ${_formatDate(ride.startedAt)}. Distance ${ride.totalDistance}',
            //             ),
            //           ),
            //         ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
