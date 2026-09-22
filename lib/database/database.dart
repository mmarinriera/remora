import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

class AppDatabase {
  static const _databaseName = 'rides.db';
  static const _databaseVersion = 1;

  final sqflite.DatabaseFactory _databaseFactory;
  final String? _path;

  sqflite.Database? _database;

  AppDatabase({sqflite.DatabaseFactory? databaseFactory, this._path})
    : _databaseFactory = databaseFactory ?? sqflite.databaseFactory;

  Future<sqflite.Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<sqflite.Database> _openDatabase() async {
    final path =
        _path ?? join(await _databaseFactory.getDatabasesPath(), _databaseName);

    return _databaseFactory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _createDatabase,
      ),
    );
  }

  Future<void> _createDatabase(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE rides (
        id TEXT PRIMARY KEY,
        started_at TEXT NOT NULL,
        finished_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE track_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ride_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        speed REAL,
        heading REAL,
        accuracy REAL,
        FOREIGN KEY (ride_id) REFERENCES rides(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_track_points_ride_id
      ON track_points(ride_id)
    ''');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
