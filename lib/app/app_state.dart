import 'package:flutter/material.dart';
import 'package:remora/models/ride.dart';
import 'package:remora/repositories/ride_repository.dart';
import 'package:remora/services/ride_tracker.dart';

class AppState extends ChangeNotifier {
  final RideRepository repository;
  final RideTracker tracker;
  List<Ride> rides = [];
  Ride? activeRide;

  AppState(this.repository, this.tracker);

  void addRide(Ride ride) {
    rides.add(ride);
    notifyListeners();
  }
}
