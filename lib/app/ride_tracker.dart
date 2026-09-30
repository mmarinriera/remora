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

  String? _currentRideId;
  DateTime? _currentRideStart;
  double? _currentRideDistance;
  TrackPoint? _currentPosition;
  final List<TrackPoint> _currentRidePoints = [];
  bool _trackActive = false;

  DateTime? get currentRideStart => _currentRideStart;
  double? get currentRideDistance => _currentRideDistance;
  TrackPoint? get currentPosition => _currentPosition;
  List<TrackPoint> get currentRidePoints =>
      List.unmodifiable(_currentRidePoints);

  bool get trackActive => _trackActive;

  RideTracker(this._locationService, this._repository);

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

    final ride = Ride(id: const Uuid().v4(), startedAt: DateTime.now());
    _currentRideId = ride.id;
    _currentRideStart = ride.startedAt;
    _currentRideDistance = 0.0;

    await _repository.createRide(ride);
    notifyListeners();

    _locationSubscription = _locationService.positionStream.listen((
      point,
    ) async {
      _updateCurrentRideData(point);
      await _handleTrackPoint(point);
      notifyListeners();
    });
  }

  Future<void> stopTrack() async {
    if (!_trackActive) {
      return;
    }
    _trackActive = false;

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    final rideId = _currentRideId;
    final totalDistance = _currentRideDistance;

    if (rideId != null) {
      await _repository.finishRide(
        rideId,
        DateTime.now(),
        totalDistance ?? 0.0,
      );
    }
    _resetCurrentRideData();
    notifyListeners();
  }

  Future<List<Ride>> getRides() async {
    return await _repository.getRides();
  }

  void _updateCurrentRideData(TrackPoint point) {
    final TrackPoint? currentPosition = _currentPosition;
    final double? distance = _currentRideDistance;

    if (currentPosition == null || distance == null) {
      _currentRideDistance = 0.0;
    } else {
      _currentRideDistance =
          distance +
          _locationService.distanceBetweenPoints(currentPosition, point);
    }

    _currentPosition = point;
    _currentRidePoints.add(point);
    print('point: $point');
  }

  Future<void> _handleTrackPoint(TrackPoint point) async {
    final rideId = _currentRideId;
    if (rideId == null) {
      return;
    }
    await _repository.addTrackPoint(rideId, point);
  }

  void _resetCurrentRideData() {
    _currentRideId = null;
    _currentRideStart = null;
    _currentRideDistance = null;
    _currentPosition = null;
    _currentRidePoints.clear();
  }

  @override
  Future<void> dispose() async {
    await stopTrack();
    notifyListeners();
    super.dispose();
  }
}
