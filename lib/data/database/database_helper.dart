import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'finance_tracker.db'),
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            iconCode INTEGER NOT NULL,
            colorValue INTEGER NOT NULL,
            monthlyBudget INTEGER,
            isDefault INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            amount INTEGER NOT NULL,
            categoryId INTEGER NOT NULL,
            date TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE settings(
              key TEXT PRIMARY KEY,
              value TEXT
            )
          ''');
        }
      },
      version: 2,
    );
  }
}
