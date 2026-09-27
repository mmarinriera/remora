class Ride {
  final String id;
  final DateTime startedAt;
  DateTime? finishedAt;
  double? totalDistance;

  Ride({
    required this.id,
    required this.startedAt,
    this.finishedAt,
    this.totalDistance,
  });

  @override
  String toString() {
    return 'Ride('
        'id: $id, '
        'started: $startedAt, '
        'finished: ${finishedAt ?? '-'}, '
        'distance: ${totalDistance ?? '-'}'
        ')';
  }
}
