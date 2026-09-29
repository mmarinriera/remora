import 'package:flutter/material.dart';
import 'package:remora/models/ride.dart';
import 'package:remora/models/track_point.dart';
import 'package:remora/utils.dart';
import 'package:remora/widgets/ride_map.dart';
import 'package:provider/provider.dart';
import 'package:remora/app/app_state.dart';

class ActiveRideScreen extends StatelessWidget {
  final String title;
  const ActiveRideScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final DateTime? rideStart = context
        .watch<AppState>()
        .tracker
        .currentRideStart;
    final TrackPoint? currentPosition = context
        .watch<AppState>()
        .tracker
        .currentPosition;

    final double? currentDistance = context
        .watch<AppState>()
        .tracker
        .currentRideDistance;

    final List<TrackPoint> trackPoints = context
        .watch<AppState>()
        .tracker
        .currentRidePoints;

    final String rideStartFmt = rideStart != null ? formatDate(rideStart) : '-';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Column(
        children: [
          Text('Ride started on: $rideStartFmt'),
          Text('Ride duration: #TODO'),
          Text('Total distance: ${currentDistance ?? '-'}'),
          SizedBox(
            height: 300,
            child: RideMap(points: trackPoints, centerPoint: currentPosition),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          context.read<AppState>().stopRide();
          Navigator.pop(context);
        },
        // foregroundColor: customizations[index].$1,
        // backgroundColor: customizations[index].$2,
        // shape: customizations[index].$3,
        child: const Icon(Icons.stop),
      ),
    );
  }
}
