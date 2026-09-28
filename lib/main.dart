import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remora/app/app.dart';
import 'package:remora/app/app_state.dart';
import 'package:remora/database/database.dart';

import 'services/ride_tracker.dart';
import 'services/location_service.dart';
import 'repositories/ride_repository.dart';

void main() {
  final database = AppDatabase();
  final repository = SqliteRideRepository(database);
  final locationService = LocationService();
  final tracker = RideTracker(locationService, repository);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(repository, tracker),
      child: const RemoraApp(),
    ),
  );
}
