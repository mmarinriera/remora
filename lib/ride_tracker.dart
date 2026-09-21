import 'dart:async';

import 'services/location_service.dart';
import 'models/track_point.dart';
import 'models/ride.dart';

class RideTracker {
  final LocationService _locationService = LocationService();
  StreamSubscription<TrackPoint>? _locationSubscription;
  Ride? _currentRide;
  TrackPoint? _currentPosition;
  bool _trackActive = false;

  bool get trackActive => _trackActive;
  TrackPoint? get currentPosition => _currentPosition;
  DateTime? get rideStart => _currentRide?.startedAt;
  double? get rideDistance => _currentRide?.totalDistance();

  Future<void> startTrack() async {
    if (_trackActive) {
      return;
    }
    _trackActive = true;

    final permissionGranted = await _locationService.checkPermission();
    if (!permissionGranted) {
      return;
    }

    _currentRide = Ride(id: 'new_ride', startedAt: DateTime.now());

    _locationSubscription = _locationService.positionStream.listen((point) {
      _currentRide?.addPoint(point);
      _currentPosition = point;
      print('point: $point');
    });
  }

  Future<void> stopTrack() async {
    if (!_trackActive) {
      return;
    }
    _trackActive = false;

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    _currentRide?.finishedAt = DateTime.now();

    print('Ride finished: $_currentRide');
    // TODO: save ride in storage.
    _currentRide = null;
  }

  Future<void> dispose() async {
    await stopTrack();
  }
}
