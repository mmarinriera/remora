import 'package:flutter/material.dart';
import 'package:remora/models/ride.dart';
import 'package:remora/services/ride_tracker.dart';

class AppState extends ChangeNotifier {
  final RideTracker tracker;
  List<Ride> rides = [];
  Ride? activeRide;

  AppState(this.tracker);

  Future<void> addRide(Ride ride) async {
    rides.add(ride);
    notifyListeners();
  }

  Future<void> startRide() async {
    await tracker.startTrack();
    notifyListeners();
  }

  Future<void> stopRide() async {
    await tracker.stopTrack();
    notifyListeners();
  }
}
