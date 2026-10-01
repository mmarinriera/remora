import 'package:flutter/material.dart';
import 'package:remora/models/ride.dart';
import 'package:remora/models/track_point.dart';
import 'package:remora/utils.dart';
import 'package:remora/widgets/ride_map.dart';

class RideDetailsScreen extends StatelessWidget {
  final Ride ride;
  final List<TrackPoint> points;
  const RideDetailsScreen({
    super.key,
    required this.ride,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final Duration? duration = ride.duration;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(formatDate(ride.startedAt)),
      ),
      body: Column(
        children: [
          Text('Start time: ${formatTime(ride.startedAt)}'),
          Text(
            'Ride duration: ${duration != null ? formatDuration(duration) : '-'}',
          ),
          Text('Total distance: ${ride.totalDistance ?? '-'}'),
          SizedBox(
            height: 300,
            child: RideMap(points: points, showFullRide: true),
          ),
        ],
      ),
    );
  }
}
