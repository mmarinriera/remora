import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remora/app/ride_tracker.dart';
import 'package:remora/screens/active_ride_screen.dart';
import 'package:remora/screens/ride_details_screen.dart';
import 'package:remora/utils.dart';

class RidesScreen extends StatelessWidget {
  final String title;
  const RidesScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final RideTracker rideTracker = context.watch<RideTracker>();
    final rides = rideTracker.pastRides;

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
          final String durationFmt = duration != null
              ? formatDuration(duration)
              : '-';
          final double? distance = ride.totalDistance;
          final String distanceFmt = distance != null
              ? '${distance.toStringAsFixed(2)}m'
              : '-';
          return ListTile(
            title: Text(formatDate(ride.startedAt)),
            subtitle: Text('Duration: $durationFmt\nDistance: $distanceFmt'),
            onTap: () async {
              final points = await context.read<RideTracker>().getTrackPoints(
                ride.id,
              );

              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) =>
                      RideDetailsScreen(ride: ride, points: points),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: !rideTracker.trackActive
            ? Text('Start track')
            : Text('Back to track'),
        onPressed: () async {
          await context.read<RideTracker>().startTrack();

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (context) => ActiveRideScreen()),
          );
        },
        // foregroundColor: customizations[index].$1,
        // backgroundColor: customizations[index].$2,
        // shape: customizations[index].$3,
        icon: const Icon(Icons.navigation),
      ),
    );
  }
}
