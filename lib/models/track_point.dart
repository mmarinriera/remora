class TrackPoint {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;

  TrackPoint({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
  });

  @override
  String toString() {
    return 'TrackPoint('
        'timestamp: $timestamp, '
        'lat: $latitude, '
        'long: $longitude, '
        'acc: $accuracy'
        ')';
  }
}
