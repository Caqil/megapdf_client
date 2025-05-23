// lib/data/database/database_helper.dart
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/folder_model.dart';
import '../models/recent_file_model.dart';
import '../models/file_folder_link.dart';

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
      version: 2, // Increment version for schema change
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create folders table
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        path TEXT NOT NULL UNIQUE,
        parent_id INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for folders
    await db
        .execute('CREATE INDEX idx_folders_parent_id ON folders(parent_id)');
    await db.execute('CREATE INDEX idx_folders_path ON folders(path)');

    // Create recent files table
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

    // Create file_folder_links table
    await db.execute('''
      CREATE TABLE file_folder_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        folder_id INTEGER NOT NULL,
        added_at INTEGER NOT NULL,
        metadata TEXT,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE,
        UNIQUE(file_path, folder_id)
      )
    ''');

    // Create indexes for file_folder_links
    await db.execute(
        'CREATE INDEX idx_file_folder_links_folder_id ON file_folder_links(folder_id)');
    await db.execute(
        'CREATE INDEX idx_file_folder_links_file_path ON file_folder_links(file_path)');

    // Insert default root folder
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('folders', {
      'name': 'MegaPDF',
      'path': '/MegaPDF',
      'parent_id': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add file_folder_links table
      await db.execute('''
        CREATE TABLE file_folder_links (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          file_path TEXT NOT NULL,
          file_name TEXT NOT NULL,
          folder_id INTEGER NOT NULL,
          added_at INTEGER NOT NULL,
          metadata TEXT,
          FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE,
          UNIQUE(file_path, folder_id)
        )
      ''');

      await db.execute(
          'CREATE INDEX idx_file_folder_links_folder_id ON file_folder_links(folder_id)');
      await db.execute(
          'CREATE INDEX idx_file_folder_links_file_path ON file_folder_links(file_path)');
    }
  }

  // Folder operations
  Future<int> insertFolder(FolderModel folder) async {
    final db = await database;
    return await db.insert('folders', folder.toMap());
  }

  Future<List<FolderModel>> getFolders({int? parentId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;

    if (parentId == null) {
      maps = await db.query(
        'folders',
        where: 'parent_id IS NULL',
        orderBy: 'name ASC',
      );
    } else {
      maps = await db.query(
        'folders',
        where: 'parent_id = ?',
        whereArgs: [parentId],
        orderBy: 'name ASC',
      );
    }

    return List.generate(maps.length, (i) => FolderModel.fromMap(maps[i]));
  }

  Future<FolderModel?> getFolderByPath(String path) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      where: 'path = ?',
      whereArgs: [path],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return FolderModel.fromMap(maps.first);
    }
    return null;
  }

  Future<FolderModel?> getFolderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return FolderModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<FolderModel>> getFolderPath(int folderId) async {
    final List<FolderModel> path = [];
    int? currentId = folderId;

    while (currentId != null) {
      final folder = await getFolderById(currentId);
      if (folder != null) {
        path.insert(0, folder);
        currentId = folder.parentId;
      } else {
        break;
      }
    }

    return path;
  }

  Future<int> updateFolder(FolderModel folder) async {
    final db = await database;
    return await db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    return await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> folderExists(String path) async {
    final folder = await getFolderByPath(path);
    return folder != null;
  }

  Future<List<FileFolderLink>> getFilesInFolder(int folderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'file_folder_links',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'file_name ASC',
    );

    return maps.map((map) {
      if (map['metadata'] != null && map['metadata'].isNotEmpty) {
        try {
          map['metadata'] = jsonDecode(map['metadata']);
        } catch (e) {
          map['metadata'] = null;
        }
      }
      return FileFolderLink.fromMap(map);
    }).toList();
  }

  Future<FileFolderLink?> getFileLocation(String filePath) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'file_folder_links',
      where: 'file_path = ?',
      whereArgs: [filePath],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      if (map['metadata'] != null && map['metadata'].isNotEmpty) {
        try {
          map['metadata'] = jsonDecode(map['metadata']);
        } catch (e) {
          map['metadata'] = null;
        }
      }
      return FileFolderLink.fromMap(map);
    }
    return null;
  }

  Future<int> moveFileToFolder({
    required String filePath,
    required int newFolderId,
  }) async {
    final db = await database;

    try {
      print('🔧 DB: Moving file $filePath to folder $newFolderId');

      // First check if the file-folder link exists
      final existingLinks = await db.query(
        'file_folder_links',
        where: 'file_path = ?',
        whereArgs: [filePath],
      );

      print('🔧 DB: Found ${existingLinks.length} existing links');

      if (existingLinks.isEmpty) {
        // No existing link, create a new one
        print('🔧 DB: No existing link found, creating new one');
        return await addFileToFolder(
          filePath: filePath,
          fileName: filePath.split('/').last,
          folderId: newFolderId,
        );
      } else {
        // Update existing link
        print('🔧 DB: Updating existing link');
        final result = await db.update(
          'file_folder_links',
          {
            'folder_id': newFolderId,
            'added_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'file_path = ?',
          whereArgs: [filePath],
        );

        print('🔧 DB: Update result: $result rows affected');
        return result;
      }
    } catch (e) {
      print('🔧 DB: Error moving file: $e');
      rethrow;
    }
  }

// Improved addFileToFolder with conflict resolution
  Future<int> addFileToFolder({
    required String filePath,
    required String fileName,
    required int folderId,
    Map<String, dynamic>? metadata,
  }) async {
    final db = await database;

    try {
      print('🔧 DB: Adding file $fileName to folder $folderId');

      final link = FileFolderLink(
        filePath: filePath,
        fileName: fileName,
        folderId: folderId,
        addedAt: DateTime.now(),
        metadata: metadata,
      );

      final map = link.toMap();
      if (map['metadata'] != null) {
        map['metadata'] = jsonEncode(map['metadata']);
      }

      // Use INSERT OR REPLACE to handle conflicts
      final result = await db.insert(
        'file_folder_links',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('🔧 DB: Insert result: $result');
      return result;
    } catch (e) {
      print('🔧 DB: Error adding file to folder: $e');
      rethrow;
    }
  }

// Method to verify folder exists before operations
  Future<bool> verifyFolderExists(int folderId) async {
    final db = await database;

    try {
      final result = await db.query(
        'folders',
        where: 'id = ?',
        whereArgs: [folderId],
      );

      return result.isNotEmpty;
    } catch (e) {
      print('🔧 DB: Error verifying folder exists: $e');
      return false;
    }
  }

// Method to get detailed folder information for debugging
  Future<Map<String, dynamic>?> getFolderDetails(int folderId) async {
    final db = await database;

    try {
      final result = await db.query(
        'folders',
        where: 'id = ?',
        whereArgs: [folderId],
      );

      if (result.isNotEmpty) {
        final folder = result.first;

        // Get file count in this folder
        final fileCount = await db.rawQuery(
          'SELECT COUNT(*) as count FROM file_folder_links WHERE folder_id = ?',
          [folderId],
        );

        // Get subfolder count
        final subfolderCount = await db.rawQuery(
          'SELECT COUNT(*) as count FROM folders WHERE parent_id = ?',
          [folderId],
        );

        return {
          ...folder,
          'file_count': fileCount.first['count'],
          'subfolder_count': subfolderCount.first['count'],
        };
      }

      return null;
    } catch (e) {
      print('🔧 DB: Error getting folder details: $e');
      return null;
    }
  }

// Method to check for circular folder references
  Future<bool> wouldCreateCircularReference(
      int sourceFolderId, int targetFolderId) async {
    if (sourceFolderId == targetFolderId) {
      return true;
    }

    final db = await database;

    try {
      // Get the path from target folder to root
      int? currentId = targetFolderId;
      final visitedIds = <int>{};

      while (currentId != null) {
        if (visitedIds.contains(currentId)) {
          // Already visited this folder, circular reference detected
          return true;
        }

        if (currentId == sourceFolderId) {
          // Target folder is a descendant of source folder
          return true;
        }

        visitedIds.add(currentId);

        final result = await db.query(
          'folders',
          columns: ['parent_id'],
          where: 'id = ?',
          whereArgs: [currentId],
        );

        if (result.isEmpty) {
          break;
        }

        currentId = result.first['parent_id'] as int?;
      }

      return false;
    } catch (e) {
      print('🔧 DB: Error checking circular reference: $e');
      return true; // Assume circular reference to be safe
    }
  }

// Method to cleanup orphaned file links
  Future<int> cleanupOrphanedFileLinks() async {
    final db = await database;

    try {
      // Delete file links that point to non-existent folders
      final result = await db.delete(
        'file_folder_links',
        where: 'folder_id NOT IN (SELECT id FROM folders)',
      );

      print('🔧 DB: Cleaned up $result orphaned file links');
      return result;
    } catch (e) {
      print('🔧 DB: Error cleaning up orphaned file links: $e');
      return 0;
    }
  }

// Method to get all file paths in a folder (for debugging)
  Future<List<String>> getFilePathsInFolder(int folderId) async {
    final db = await database;

    try {
      final result = await db.query(
        'file_folder_links',
        columns: ['file_path'],
        where: 'folder_id = ?',
        whereArgs: [folderId],
      );

      return result.map((row) => row['file_path'] as String).toList();
    } catch (e) {
      print('🔧 DB: Error getting file paths: $e');
      return [];
    }
  }

  Future<int> removeFileFromFolder(String filePath) async {
    final db = await database;
    return await db.delete(
      'file_folder_links',
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
  }

  Future<int> removeFilesFromFolder(int folderId) async {
    final db = await database;
    return await db.delete(
      'file_folder_links',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
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
      // Parse metadata JSON
      if (map['metadata'] != null && map['metadata'].isNotEmpty) {
        try {
          map['metadata'] = jsonDecode(map['metadata']);
        } catch (e) {
          map['metadata'] = null;
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

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
