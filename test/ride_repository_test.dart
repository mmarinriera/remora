import 'package:remora/database/database.dart';
import 'package:remora/models/ride.dart';
import 'package:remora/models/track_point.dart';
import 'package:remora/repositories/ride_repository.dart';
import 'package:test/test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  group('test RideRepository', () {
    test('test Ride storage and retrieval', () async {
      final database = AppDatabase(
        databaseFactory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      );

      final repository = SqliteRideRepository(database);
      final ride = Ride(id: 'test-ride', startedAt: DateTime.now());

      await repository.createRide(ride);

      final point = TrackPoint(
        timestamp: DateTime.now(),
        latitude: 48.137,
        longitude: 11.575,
        altitude: 520,
        speed: 5,
        heading: 90,
        accuracy: 4,
      );

      await repository.addTrackPoint(ride.id, point);

      final finishTime = DateTime.now();
      final totalDistance = 50.0;
      await repository.finishRide(ride.id, finishTime, totalDistance);

      final storedRides = await repository.getRides();
      final points = await repository.getTrackPoints(ride.id);

      expect(storedRides.length, 1);
      expect(storedRides[0].startedAt, ride.startedAt);
      expect(storedRides[0].finishedAt, finishTime);
      expect(storedRides[0].totalDistance, totalDistance);

      expect(points.length, 1);
      expect(points[0].timestamp, point.timestamp);
      expect(points[0].latitude, point.latitude);
      expect(points[0].longitude, point.longitude);
      expect(points[0].altitude, point.altitude);
      expect(points[0].speed, point.speed);
      expect(points[0].heading, point.heading);
      expect(points[0].accuracy, point.accuracy);
    });
  });
}
