import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';

/// Singleton SQLite helper for Umrah Ease offline data.
///
/// Tables:
///   training_progress  — lesson completion tracking (Education Hub)
///   bookmarks          — saved hotels, lessons, and services
///   checklist_items    — packing checklist (Packing Checklist screen)
///   cached_rituals     — offline ritual step content (Live Ritual Guide)
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createTrainingProgressTable);
    await db.execute(_createBookmarksTable);
    await db.execute(_createChecklistItemsTable);
    await db.execute(_createCachedRitualsTable);
    await db.execute(_createUmrahGuidesTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(_createUmrahGuidesTable);
    }
    if (oldVersion < 3) {
      // Ensure umrah_guides exists for devices that had v2 without it.
      await db.execute(
        'CREATE TABLE IF NOT EXISTS umrah_guides ('
        '  id          TEXT    PRIMARY KEY,'
        '  title       TEXT    NOT NULL,'
        '  category    TEXT    NOT NULL,'
        '  body        TEXT    NOT NULL,'
        '  arabic_text TEXT,'
        '  step_order  INTEGER NOT NULL DEFAULT 0,'
        '  icon_name   TEXT,'
        '  cached_at   TEXT    NOT NULL'
        ')',
      );
    }
    if (oldVersion < 4) {
      // checklist_items was added to _onCreate but never to _onUpgrade,
      // so existing users upgrading from v1/v2/v3 were missing the table.
      await db.execute(
        'CREATE TABLE IF NOT EXISTS checklist_items ('
        '  id          INTEGER PRIMARY KEY AUTOINCREMENT,'
        '  category    TEXT    NOT NULL,'
        '  item_name   TEXT    NOT NULL,'
        '  is_checked  INTEGER NOT NULL DEFAULT 0,'
        '  is_custom   INTEGER NOT NULL DEFAULT 0,'
        '  sort_order  INTEGER NOT NULL DEFAULT 0,'
        '  created_at  TEXT    NOT NULL'
        ')',
      );
    }
  }

  // ── Table DDL ─────────────────────────────────────────────────────────────

  static const _createTrainingProgressTable = '''
    CREATE TABLE training_progress (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      lesson_id     TEXT    NOT NULL UNIQUE,
      lesson_name   TEXT    NOT NULL,
      ritual_group  TEXT    NOT NULL,
      progress_pct  REAL    NOT NULL DEFAULT 0,
      completed     INTEGER NOT NULL DEFAULT 0,
      completed_at  TEXT,
      updated_at    TEXT    NOT NULL
    )
  ''';

  static const _createBookmarksTable = '''
    CREATE TABLE bookmarks (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      type          TEXT    NOT NULL,
      reference_id  TEXT    NOT NULL,
      title         TEXT    NOT NULL,
      subtitle      TEXT,
      data_json     TEXT,
      created_at    TEXT    NOT NULL,
      UNIQUE(type, reference_id)
    )
  ''';

  static const _createChecklistItemsTable = '''
    CREATE TABLE checklist_items (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      category    TEXT    NOT NULL,
      item_name   TEXT    NOT NULL,
      is_checked  INTEGER NOT NULL DEFAULT 0,
      is_custom   INTEGER NOT NULL DEFAULT 0,
      sort_order  INTEGER NOT NULL DEFAULT 0,
      created_at  TEXT    NOT NULL
    )
  ''';

  static const _createCachedRitualsTable = '''
    CREATE TABLE cached_rituals (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      ritual_name   TEXT    NOT NULL,
      step_number   INTEGER NOT NULL,
      title         TEXT    NOT NULL,
      arabic_text   TEXT,
      english_text  TEXT    NOT NULL,
      audio_path    TEXT,
      cached_at     TEXT    NOT NULL,
      UNIQUE(ritual_name, step_number)
    )
  ''';

  static const _createUmrahGuidesTable = '''
    CREATE TABLE umrah_guides (
      id          TEXT    PRIMARY KEY,
      title       TEXT    NOT NULL,
      category    TEXT    NOT NULL,
      body        TEXT    NOT NULL,
      arabic_text TEXT,
      step_order  INTEGER NOT NULL DEFAULT 0,
      icon_name   TEXT,
      cached_at   TEXT    NOT NULL
    )
  ''';

  // ── Training Progress ─────────────────────────────────────────────────────

  Future<void> upsertTrainingProgress(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'training_progress',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllTrainingProgress() async {
    final db = await database;
    return db.query('training_progress', orderBy: 'ritual_group, lesson_id');
  }

  Future<Map<String, dynamic>?> getTrainingProgress(String lessonId) async {
    final db = await database;
    final rows = await db.query(
      'training_progress',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<void> addBookmark(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(String type, String referenceId) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'type = ? AND reference_id = ?',
      whereArgs: [type, referenceId],
    );
  }

  Future<bool> isBookmarked(String type, String referenceId) async {
    final db = await database;
    final rows = await db.query(
      'bookmarks',
      where: 'type = ? AND reference_id = ?',
      whereArgs: [type, referenceId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getBookmarksByType(String type) async {
    final db = await database;
    return db.query(
      'bookmarks',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
  }

  // ── Checklist Items ───────────────────────────────────────────────────────

  Future<void> insertChecklistItem(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('checklist_items', data);
  }

  Future<void> toggleChecklistItem(int id, bool isChecked) async {
    final db = await database;
    await db.update(
      'checklist_items',
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteChecklistItem(int id) async {
    final db = await database;
    await db.delete('checklist_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getChecklistByCategory(
      String category) async {
    final db = await database;
    return db.query(
      'checklist_items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'sort_order, id',
    );
  }

  Future<List<Map<String, dynamic>>> getAllChecklistItems() async {
    final db = await database;
    return db.query('checklist_items', orderBy: 'category, sort_order, id');
  }

  Future<int> getChecklistCompletionCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM checklist_items WHERE is_checked = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getChecklistTotalCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(*) as count FROM checklist_items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ── Cached Rituals ────────────────────────────────────────────────────────

  Future<void> cacheRitualStep(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'cached_rituals',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCachedRitual(
      String ritualName) async {
    final db = await database;
    return db.query(
      'cached_rituals',
      where: 'ritual_name = ?',
      whereArgs: [ritualName],
      orderBy: 'step_number',
    );
  }

  Future<bool> isRitualCached(String ritualName) async {
    final db = await database;
    final rows = await db.query(
      'cached_rituals',
      where: 'ritual_name = ?',
      whereArgs: [ritualName],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  // ── Umrah Guides ──────────────────────────────────────────────────────────

  /// Returns true when at least one guide has been cached locally.
  Future<bool> hasUmrahGuides() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM umrah_guides',
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<List<Map<String, dynamic>>> getAllUmrahGuides() async {
    final db = await database;
    return db.query('umrah_guides', orderBy: 'category, step_order');
  }

  /// Batch-inserts [guides], replacing any existing row with the same id.
  Future<void> cacheUmrahGuides(List<Map<String, dynamic>> guides) async {
    final db = await database;
    final batch = db.batch();
    for (final guide in guides) {
      batch.insert(
        'umrah_guides',
        guide,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> clearUmrahGuides() async {
    final db = await database;
    await db.delete('umrah_guides');
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
