import "track_point.dart";

class Ride {
  final String id;
  final DateTime startedAt;
  DateTime? finishedAt;
  final List<TrackPoint> points;

  Ride({
    required this.id,
    required this.startedAt,
    this.finishedAt,
    required this.points,
  });
}
