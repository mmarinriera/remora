import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../services/location_service.dart';
import '../models/track_point.dart';
import '../models/ride.dart';
import '../repositories/ride_repository.dart';
import '../services/permission_service.dart';

// App state class
class RideTracker extends ChangeNotifier {
  final LocationService _locationService;
  final RideRepository _repository;
  final PermissionService _permissionService = PermissionService();

  StreamSubscription<TrackPoint>? _locationSubscription;

  Ride? _currentRide;
  final List<TrackPoint> _currentRidePoints = [];
  List<Ride> _pastRides = [];
  bool _trackActive = false;

  DateTime? get currentRideStart => _currentRide?.startedAt;
  double? get currentRideDistance => _currentRide?.totalDistance;
  TrackPoint? get currentPosition => _currentRidePoints.lastOrNull;
  List<TrackPoint> get currentRidePoints =>
      List.unmodifiable(_currentRidePoints);

  List<Ride> get pastRides => List.unmodifiable(_pastRides);

  bool get trackActive => _trackActive;

  RideTracker(this._locationService, this._repository);

  Future<void> initialize() async {
    _pastRides = await _repository.getRides();
    notifyListeners();
  }

  Future<void> startTrack() async {
    if (_trackActive) {
      return;
    }
    _trackActive = true;

    await _permissionService.requestNotificationPermission(); //TODO: show a dialog if permission is denied.

    final permissionGranted = await _locationService.checkPermission();
    if (!permissionGranted) {
      return;
    }

    final currentRide = Ride(id: const Uuid().v4(), startedAt: DateTime.now());

    await _repository.createRide(currentRide);
    _currentRide = currentRide;

    _locationSubscription = _locationService.positionStream.listen((
      point,
    ) async {
      _updateCurrentRideData(point);
      await _handleTrackPoint(point);
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> stopTrack() async {
    if (!_trackActive) {
      return;
    }
    _trackActive = false;

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    final Ride? currentRide = _currentRide;
    final DateTime finishTime = DateTime.now();
    if (currentRide != null) {
      currentRide.finishedAt = finishTime;
      await _repository.finishRide(
        currentRide.id,
        finishTime,
        currentRide.totalDistance ?? 0.0,
      );
      _pastRides.add(currentRide);
    }
    _resetCurrentRideData();
    notifyListeners();
  }

  Future<List<Ride>> getRides() async {
    return await _repository.getRides();
  }

  Future<List<TrackPoint>> getTrackPoints(String rideId) async {
    return await _repository.getTrackPoints(rideId);
  }

  void _updateCurrentRideData(TrackPoint point) {
    final TrackPoint? lastTrackPoint = _currentRidePoints.lastOrNull;
    final Ride? currentRide = _currentRide;

    if (currentRide == null) return;

    final double? distance = currentRide.totalDistance;
    if (distance != null && lastTrackPoint != null) {
      currentRide.totalDistance =
          distance +
          _locationService.distanceBetweenPoints(lastTrackPoint, point);
    } else {
      currentRide.totalDistance = 0.0;
    }

    _currentRidePoints.add(point);
    print('point: $point');
  }

  Future<void> _handleTrackPoint(TrackPoint point) async {
    final currentRide = _currentRide;
    if (currentRide == null) {
      return;
    }
    await _repository.addTrackPoint(currentRide.id, point);
  }

  void _resetCurrentRideData() {
    _currentRide = null;
    _currentRidePoints.clear();
  }

  @override
  Future<void> dispose() async {
    await stopTrack();
    notifyListeners();
    super.dispose();
  }
}
