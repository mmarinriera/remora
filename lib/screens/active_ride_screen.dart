import 'package:flutter/material.dart';
import 'package:remora/app/ride_tracker.dart';
import 'package:remora/models/track_point.dart';
import 'package:remora/utils.dart';
import 'package:remora/widgets/ride_map.dart';
import 'package:provider/provider.dart';

class ActiveRideScreen extends StatelessWidget {
  const ActiveRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rideTracker = context.watch<RideTracker>();

    final DateTime? rideStart = rideTracker.currentRideStart;
    final double? currentDistance = rideTracker.currentRideDistance;
    final List<TrackPoint> trackPoints = rideTracker.currentRidePoints;

    final String rideStartFmt = rideStart != null ? formatTime(rideStart) : '-';
    final String rideDistanceFmt = currentDistance != null
        ? '${currentDistance.toStringAsFixed(2)}m'
        : '-';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Currently tracking...'),
      ),
      body: Column(
        children: [
          Text('Start time: $rideStartFmt'),
          Text('Ride duration: #TODO'),
          Text('Total distance: $rideDistanceFmt'),
          SizedBox(
            height: 300,
            child: RideMap(
              points: trackPoints,
              currentPosition: trackPoints.lastOrNull,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Finish track'),
        onPressed: () async {
          await context.read<RideTracker>().stopTrack();
          if (!context.mounted) return;
          Navigator.pop(context);
        },
        // foregroundColor: customizations[index].$1,
        // backgroundColor: customizations[index].$2,
        // shape: customizations[index].$3,
        icon: const Icon(Icons.stop),
      ),
    );
  }
}
