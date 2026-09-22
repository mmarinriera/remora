class Ride {
  final String id;
  final DateTime startedAt;
  DateTime? finishedAt;

  Ride({required this.id, required this.startedAt, this.finishedAt});

  @override
  String toString() {
    return 'Ride('
        'id: $id, '
        'started: $startedAt, '
        'finished: ${finishedAt ?? '-'}'
        ')';
  }
}
