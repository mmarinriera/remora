import "track_point.dart";

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
        'npoints: ${points.length}'
        ')';
  }

  void addPoint(TrackPoint point) {
    points.add(point);
  }
}
