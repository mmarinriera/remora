import '../models/ride.dart';
import '../models/track_point.dart';
import '../database/database.dart';

abstract interface class RideRepository {
  Future<void> createRide(Ride ride);

  Future<void> addTrackPoint(String rideId, TrackPoint point);

  Future<void> finishRide(String rideId, DateTime finishedAt);

  Future<List<Ride>> getRides();

  Future<List<TrackPoint>> getTrackPoints(String rideId);
}

class SqliteRideRepository implements RideRepository {
  final AppDatabase _database;

  SqliteRideRepository(this._database);

  @override
  Future<void> createRide(Ride ride) async {
    final db = await _database.database;

    await db.insert('rides', {
      'id': ride.id,
      'started_at': ride.startedAt.toIso8601String(),
      'finished_at': ride.finishedAt?.toIso8601String(),
    });
  }

  @override
  Future<void> addTrackPoint(String rideId, TrackPoint point) async {
    final db = await _database.database;

    await db.insert('track_points', {
      'ride_id': rideId,
      'timestamp': point.timestamp.toIso8601String(),
      'latitude': point.latitude,
      'longitude': point.longitude,
      'altitude': point.altitude,
      'speed': point.speed,
      'heading': point.heading,
      'accuracy': point.accuracy,
    });
  }

  @override
  Future<void> finishRide(String rideId, DateTime finishedAt) async {
    final db = await _database.database;

    await db.update(
      'rides',
      {'finished_at': finishedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [rideId],
    );
  }

  @override
  Future<List<Ride>> getRides() async {
    final db = await _database.database;
    List<Map<String, Object?>> result = await db.query('rides');

    if (result.isEmpty) {
      return [];
    }

    return [
      for (final row in result)
        Ride(
          id: row['id'] as String,
          startedAt: DateTime.parse(row['started_at'] as String),
          finishedAt: row['finished_at'] == null
              ? null
              : DateTime.parse(row['finished_at'] as String),
        ),
    ];
  }

  @override
  Future<List<TrackPoint>> getTrackPoints(String rideId) async {
    final db = await _database.database;

    final result = await db.query(
      'track_points',
      where: 'ride_id = ?',
      whereArgs: [rideId],
      orderBy: 'timestamp ASC',
    );
    if (result.isEmpty) {
      return [];
    }

    return [
      for (final row in result)
        TrackPoint(
          timestamp: DateTime.parse(row['timestamp'] as String),
          latitude: row['latitude'] as double,
          longitude: row['longitude'] as double,
          altitude: row['altitude'] as double?,
          speed: row['speed'] as double?,
          heading: row['heading'] as double?,
          accuracy: row['accuracy'] as double?,
        ),
    ];
  }
}
