import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/check_in_record.dart';
import '../models/finish_class_record.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const _dbName = 'smart_class_checkin.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<void> initialize() async {
    if (_database != null) {
      return;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE check_in_records(
            id TEXT PRIMARY KEY,
            createdAt TEXT NOT NULL,
            qrCodeValue TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            previousTopic TEXT NOT NULL,
            expectedTopicToday TEXT NOT NULL,
            moodBeforeClass INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE finish_class_records(
            id TEXT PRIMARY KEY,
            createdAt TEXT NOT NULL,
            qrCodeValue TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            learnedToday TEXT NOT NULL,
            classFeedback TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<Database> get _db async {
    if (_database == null) {
      await initialize();
    }
    return _database!;
  }

  Future<void> insertCheckIn(CheckInRecord record) async {
    final db = await _db;
    await db.insert(
      'check_in_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFinishClass(FinishClassRecord record) async {
    final db = await _db;
    await db.insert(
      'finish_class_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, String>>> getRecentRecords({int limit = 10}) async {
    final db = await _db;

    final checkIns = await db.query(
      'check_in_records',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    final finishes = await db.query(
      'finish_class_records',
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    final merged = <Map<String, String>>[
      ...checkIns.map(
        (row) => {
          'type': 'Check-in',
          'createdAt': row['createdAt'] as String,
          'details': (row['expectedTopicToday'] as String),
        },
      ),
      ...finishes.map(
        (row) => {
          'type': 'Finish Class',
          'createdAt': row['createdAt'] as String,
          'details': (row['learnedToday'] as String),
        },
      ),
    ];

    merged.sort(
      (a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''),
    );

    return merged.take(limit).toList();
  }
}
