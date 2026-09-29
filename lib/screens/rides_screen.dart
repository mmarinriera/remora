import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remora/app/ride_tracker.dart';
import 'package:remora/models/ride.dart';
import 'package:remora/models/track_point.dart';
import 'package:remora/screens/active_ride_screen.dart';
import 'package:remora/screens/ride_details_screen.dart';
import 'package:remora/utils.dart';

class RidesScreen extends StatelessWidget {
  final String title;
  const RidesScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // final rides = context.watch<AppState>().rides;
    final rides = [
      Ride(
        id: "ride0",
        startedAt: DateTime(2025, 11, 29, 15, 30),
        finishedAt: DateTime(2025, 11, 29, 16),
        totalDistance: 500,
      ),
      Ride(
        id: "ride1",
        startedAt: DateTime(2026, 11, 28, 15, 30),
        finishedAt: DateTime(2026, 11, 29, 15, 30),
        totalDistance: 200,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: rides.length,
        itemBuilder: (BuildContext context, int index) {
          final ride = rides[index];
          final Duration? duration = ride.duration;
          return ListTile(
            title: Text(
              'Start: ${formatDate(ride.startedAt)}\nDuration: ${duration != null ? formatDuration(duration) : '-'}\nDistance: ${ride.totalDistance ?? '-'}',
            ),
            onTap: () async {
              // final points = await context
              //     .read<RideTracker>()
              //     .repository
              //     .getTrackPoints(ride.id);

              final points = [
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
              ];

              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => RideDetailsScreen(
                    title: ride.id,
                    ride: ride,
                    points: points,
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.read<RideTracker>().startTrack();
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => ActiveRideScreen(title: "Ride"),
            ),
          );
        },
        // foregroundColor: customizations[index].$1,
        // backgroundColor: customizations[index].$2,
        // shape: customizations[index].$3,
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
