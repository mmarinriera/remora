import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remora/app/app.dart';
import 'package:remora/database/database.dart';

import 'app/ride_tracker.dart';
import 'services/location_service.dart';
import 'repositories/ride_repository.dart';

void main() {
  final database = AppDatabase();
  final repository = SqliteRideRepository(database);
  final locationService = LocationService();

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final tracker = RideTracker(locationService, repository);
        tracker.initialize();
        return tracker;
      },
      child: const RemoraApp(),
    ),
  );
}
