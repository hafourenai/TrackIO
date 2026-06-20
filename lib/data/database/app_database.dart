import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  static Database? _db;

  static Database get instance {
    if (_db == null) {
      throw StateError('Database not initialized. Call AppDatabase.init() first.');
    }
    return _db!;
  }

  static bool get isInitialized => _db != null;

  static Future<void> init() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'trackio.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            note TEXT,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('CREATE INDEX idx_date ON transactions(date)');
        await db.execute('CREATE INDEX idx_type ON transactions(type)');
        await db.execute('CREATE INDEX idx_category ON transactions(category)');
      },
    );
  }

  static Future<void> reset() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
