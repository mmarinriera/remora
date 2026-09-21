import "track_point.dart";

import 'package:geolocator/geolocator.dart';

class Ride {
  final String id;
  final DateTime startedAt;
  DateTime? finishedAt;
  final List<TrackPoint> points = [];

  Ride({required this.id, required this.startedAt});

  @override
  String toString() {
    return 'Ride('
        'id: $id, '
        'started: $startedAt, '
        'finished: ${finishedAt ?? '-'}, '
        'npoints: ${points.length}, '
        'distance: ${totalDistance()}'
        ')';
  }

  void addPoint(TrackPoint point) {
    points.add(point);
  }

  double totalDistance() {
    double totalDistance = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      totalDistance += Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
    }
    return totalDistance;
  }
}
