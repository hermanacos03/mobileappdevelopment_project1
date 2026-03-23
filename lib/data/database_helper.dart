import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habit_mastery.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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
        created_at TEXT NOT NULL,
        habit_frequency INTEGER NOT NULL DEFAULT 1,
        frequency_counter INTEGER NOT NULL DEFAULT 0,
        next_reset INTEGER NOT NULL DEFAULT 0
      )
    ''');

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

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE habits ADD COLUMN habit_frequency INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE habits ADD COLUMN frequency_counter INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE habits ADD COLUMN next_reset INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit);
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

  Future<int> insertOccurrence(Map<String, dynamic> occurrence) async {
    final db = await instance.database;
    return await db.insert(
      'habit_occurrences',
      occurrence,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<List<Map<String, dynamic>>> getAllOccurrences() async {
    final db = await instance.database;
    return await db.query(
      'habit_occurrences',
      orderBy: 'date ASC',
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

  // 🔥 ONLY ADDITION
  Future<void> seedTestStreakDirect({
    required int habitId,
    required int streakDays,
  }) async {
    final db = await instance.database;
    final now = DateTime.now();

    await db.delete(
      'habit_occurrences',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );

    for (int i = 0; i < streakDays; i++) {
      final date = now.subtract(Duration(days: i));

      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      await db.insert(
        'habit_occurrences',
        {
          'habit_id': habitId,
          'date': formattedDate,
          'status': 'done',
          'completed_at': date.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}