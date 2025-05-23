// lib/data/database/database_helper.dart
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recent_file_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'megapdf.db');

    return await openDatabase(
      path,
      version: 3, // Increment version for schema change
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Only create recent_files table
    await db.execute('''
      CREATE TABLE recent_files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_file_name TEXT NOT NULL,
        result_file_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        original_file_path TEXT NOT NULL,
        result_file_path TEXT,
        original_size TEXT NOT NULL,
        result_size TEXT,
        processed_at INTEGER NOT NULL,
        metadata TEXT
      )
    ''');

    // Create indexes for recent files
    await db.execute(
        'CREATE INDEX idx_recent_files_processed_at ON recent_files(processed_at DESC)');
    await db.execute(
        'CREATE INDEX idx_recent_files_operation_type ON recent_files(operation_type)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Drop folder-related tables if they exist
      await db.execute('DROP TABLE IF EXISTS file_folder_links');
      await db.execute('DROP TABLE IF EXISTS folders');
    }
  }

  // Recent files operations
  Future<int> insertRecentFile(RecentFileModel recentFile) async {
    final db = await database;
    final map = recentFile.toMap();

    // Convert metadata to JSON string
    if (map['metadata'] != null) {
      map['metadata'] = jsonEncode(map['metadata']);
    }

    return await db.insert('recent_files', map);
  }

  Future<List<RecentFileModel>> getRecentFiles({
    int limit = 50,
    String? operationType,
  }) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (operationType != null) {
      maps = await db.query(
        'recent_files',
        where: 'operation_type = ?',
        whereArgs: [operationType],
        orderBy: 'processed_at DESC',
        limit: limit,
      );
    } else {
      maps = await db.query(
        'recent_files',
        orderBy: 'processed_at DESC',
        limit: limit,
      );
    }

    return maps.map((map) {
      // Parse metadata JSON safely
      if (map['metadata'] != null) {
        final String metadataStr = map['metadata'] as String;
        if (metadataStr.isNotEmpty) {
          try {
            map['metadata'] = jsonDecode(metadataStr);
          } catch (e) {
            print('🔧 DB: Failed to parse metadata: $e');
            map['metadata'] = null;
          }
        }
      }
      return RecentFileModel.fromMap(map);
    }).toList();
  }

  Future<Map<String, int>> getRecentFilesStats() async {
    final db = await database;

    // Get today's count
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    final todayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM recent_files 
      WHERE processed_at >= ? AND processed_at < ?
    ''', [
      startOfToday.millisecondsSinceEpoch,
      endOfToday.millisecondsSinceEpoch
    ]);

    // Get this week's count
    final startOfWeek =
        startOfToday.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final weekResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM recent_files 
      WHERE processed_at >= ? AND processed_at < ?
    ''',
        [startOfWeek.millisecondsSinceEpoch, endOfWeek.millisecondsSinceEpoch]);

    return {
      'today': (todayResult.first['count'] as int?) ?? 0,
      'thisWeek': (weekResult.first['count'] as int?) ?? 0,
    };
  }

  Future<Map<String, int>> getOperationStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT operation_type, COUNT(*) as count 
      FROM recent_files 
      GROUP BY operation_type
    ''');

    final stats = <String, int>{};
    for (final row in result) {
      stats[row['operation_type'] as String] = row['count'] as int;
    }

    return stats;
  }

  Future<int> deleteOldRecentFiles({int keepDays = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));

    return await db.delete(
      'recent_files',
      where: 'processed_at < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  Future<int> clearAllRecentFiles() async {
    final db = await database;
    return await db.delete('recent_files');
  }

  // Get a specific recent file by ID
  Future<RecentFileModel?> getRecentFileById(int id) async {
    final db = await database;
    final maps = await db.query(
      'recent_files',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      // Parse metadata
      final map = maps.first;
      if (map['metadata'] != null) {
        final String metadataStr = map['metadata'] as String;
        if (metadataStr.isNotEmpty) {
          try {
            map['metadata'] = jsonDecode(metadataStr);
          } catch (e) {
            print('Error parsing metadata: $e');
            map['metadata'] = null;
          }
        }
      }
      return RecentFileModel.fromMap(map);
    }
    return null;
  }

  // Get a recent file by result file path
  Future<RecentFileModel?> getRecentFileByPath(String path) async {
    final db = await database;
    final maps = await db.query(
      'recent_files',
      where: 'result_file_path = ?',
      whereArgs: [path],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      // Parse metadata
      final map = maps.first;
      if (map['metadata'] != null) {
        final String metadataStr = map['metadata'] as String;
        if (metadataStr.isNotEmpty) {
          try {
            map['metadata'] = jsonDecode(metadataStr);
          } catch (e) {
            print('Error parsing metadata: $e');
            map['metadata'] = null;
          }
        }
      }
      return RecentFileModel.fromMap(map);
    }
    return null;
  }

  // Delete a specific recent file by ID
  Future<int> deleteRecentFile(int id) async {
    final db = await database;
    return await db.delete(
      'recent_files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a recent file record
  Future<int> updateRecentFile(RecentFileModel file) async {
    if (file.id == null) return 0;

    final db = await database;
    final map = file.toMap();

    // Convert metadata to JSON string
    if (map['metadata'] != null) {
      map['metadata'] = jsonEncode(map['metadata']);
    }

    return await db.update(
      'recent_files',
      map,
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  // Update the result file path for a recent file
  Future<int> updateResultFilePath(int id, String newPath) async {
    final db = await database;
    return await db.update(
      'recent_files',
      {'result_file_path': newPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Utility method to get database size
  Future<int> getDatabaseSize() async {
    final db = await database;
    final sizeResult = await db.rawQuery('PRAGMA page_count');
    final pageCount = Sqflite.firstIntValue(sizeResult) ?? 0;

    final pageSizeResult = await db.rawQuery('PRAGMA page_size');
    final pageSize = Sqflite.firstIntValue(pageSizeResult) ?? 0;

    return pageCount * pageSize;
  }

  // Utility method to get table info
  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    final db = await database;
    return await db.rawQuery('PRAGMA table_info($tableName)');
  }

  // Utility method to get table row count
  Future<int> getTableRowCount(String tableName) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Vacuum database to reclaim space
  Future<void> vacuumDatabase() async {
    final db = await database;
    await db.execute('VACUUM');
  }
}
