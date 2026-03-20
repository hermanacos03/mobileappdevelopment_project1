import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habit_mastery.db');
    return _database!;
  }

  // Initialize DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create Tables
  Future _createDB(Database db, int version) async {
    // HABITS TABLE
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        repeat_type TEXT NOT NULL,
        day_of_week INTEGER,
        day_of_month INTEGER,
        month INTEGER,
        time_of_day TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // HABIT OCCURRENCES TABLE
    await db.execute('''
      CREATE TABLE habit_occurrences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        completed_at TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE(habit_id, date)
      )
    ''');

    // BADGES TABLE
    await db.execute('''
      CREATE TABLE badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        milestone INTEGER NOT NULL,
        achieved_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');
  }

  // =========================
  // HABIT METHODS
  // =========================

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await instance.database;
    try {
      return await db.insert('habits', habit);
    } catch (e) {
      print('Error inserting habit: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await instance.database;
    return await db.query('habits', orderBy: 'created_at DESC');
  }

  Future<int> updateHabit(int id, Map<String, dynamic> habit) async {
    final db = await instance.database;
    return await db.update(
      'habits',
      habit,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await instance.database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // OCCURRENCE METHODS
  // =========================

  Future<int> insertOccurrence(Map<String, dynamic> occurrence) async {
    final db = await instance.database;
    try {
      return await db.insert(
        'habit_occurrences',
        occurrence,
        conflictAlgorithm: ConflictAlgorithm.replace, // avoids duplicate crash
      );
    } catch (e) {
      print('Error inserting occurrence: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOccurrencesByHabit(int habitId) async {
    final db = await instance.database;
    return await db.query(
      'habit_occurrences',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
  }

  Future<int> updateOccurrence(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'habit_occurrences',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // BADGE METHODS
  // =========================

  Future<int> insertBadge(Map<String, dynamic> badge) async {
    final db = await instance.database;
    return await db.insert('badges', badge);
  }

  Future<List<Map<String, dynamic>>> getBadges(int habitId) async {
    final db = await instance.database;
    return await db.query(
      'badges',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
  }

  // =========================
  // HELPER METHODS
  // =========================

  // Get today's habits with status
  Future<List<Map<String, dynamic>>> getTodayOccurrences(String today) async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT h.*, o.status, o.id as occurrence_id
      FROM habits h
      LEFT JOIN habit_occurrences o
      ON h.id = o.habit_id AND o.date = ?
      ORDER BY h.time_of_day ASC
    ''', [today]);
  }

  // Close DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}