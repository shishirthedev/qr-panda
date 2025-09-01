import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/qr_history_item.dart';

class QRHistoryService {
  static Database? _database;
  static const String _tableName = 'qr_history';

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'qr_history.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        type INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        title TEXT,
        description TEXT,
        metadata TEXT,
        qrImagePath TEXT,
        qrData TEXT
      )
    ''');
  }

  // Insert new QR history item
  Future<void> insertQRHistory(QRHistoryItem item) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'id': item.id,
        'content': item.content,
        'type': item.type.index,
        'timestamp': item.timestamp.millisecondsSinceEpoch,
        'title': item.title,
        'description': item.description,
        'metadata': item.metadata != null ? _mapToJson(item.metadata!) : null,
        'qrImagePath': item.qrImagePath,
        'qrData': item.qrData != null ? _mapToJson(item.qrData!.toMap()) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all QR history items
  Future<List<QRHistoryItem>> getAllQRHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return QRHistoryItem.fromMap({
        'id': maps[i]['id'],
        'content': maps[i]['content'],
        'type': maps[i]['type'],
        'timestamp': maps[i]['timestamp'],
        'title': maps[i]['title'],
        'description': maps[i]['description'],
        'metadata': maps[i]['metadata'] != null ? _jsonToMap(maps[i]['metadata']) : null,
        'qrImagePath': maps[i]['qrImagePath'],
        'qrData': maps[i]['qrData'] != null ? _jsonToMap(maps[i]['qrData']) : null,
      });
    });
  }

  // Get QR history items by type
  Future<List<QRHistoryItem>> getQRHistoryByType(QRHistoryType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'type = ?',
      whereArgs: [type.index],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return QRHistoryItem.fromMap({
        'id': maps[i]['id'],
        'content': maps[i]['content'],
        'type': maps[i]['type'],
        'timestamp': maps[i]['timestamp'],
        'title': maps[i]['title'],
        'description': maps[i]['description'],
        'metadata': maps[i]['metadata'] != null ? _jsonToMap(maps[i]['metadata']) : null,
        'qrImagePath': maps[i]['qrImagePath'],
        'qrData': maps[i]['qrData'] != null ? _jsonToMap(maps[i]['qrData']) : null,
      });
    });
  }

  // Get QR history item by ID
  Future<QRHistoryItem?> getQRHistoryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return QRHistoryItem.fromMap({
      'id': maps[0]['id'],
      'content': maps[0]['content'],
      'type': maps[0]['type'],
      'timestamp': maps[0]['timestamp'],
      'title': maps[0]['title'],
      'description': maps[0]['description'],
      'metadata': maps[0]['metadata'] != null ? _jsonToMap(maps[0]['metadata']) : null,
      'qrImagePath': maps[0]['qrImagePath'],
      'qrData': maps[0]['qrData'] != null ? _jsonToMap(maps[0]['qrData']) : null,
    });
  }

  // Update QR history item
  Future<void> updateQRHistory(QRHistoryItem item) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        'content': item.content,
        'type': item.type.index,
        'timestamp': item.timestamp.millisecondsSinceEpoch,
        'title': item.title,
        'description': item.description,
        'metadata': item.metadata != null ? _mapToJson(item.metadata!) : null,
        'qrImagePath': item.qrImagePath,
        'qrData': item.qrData != null ? _mapToJson(item.qrData!.toMap()) : null,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete QR history item
  Future<void> deleteQRHistory(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all QR history
  Future<void> deleteAllQRHistory() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Search QR history items
  Future<List<QRHistoryItem>> searchQRHistory(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'content LIKE ? OR title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return QRHistoryItem.fromMap({
        'id': maps[i]['id'],
        'content': maps[i]['content'],
        'type': maps[i]['type'],
        'timestamp': maps[i]['timestamp'],
        'title': maps[i]['title'],
        'description': maps[i]['description'],
        'metadata': maps[i]['metadata'] != null ? _jsonToMap(maps[i]['metadata']) : null,
        'qrImagePath': maps[i]['qrImagePath'],
        'qrData': maps[i]['qrData'] != null ? _jsonToMap(maps[i]['qrData']) : null,
      });
    });
  }

  // Get QR history count
  Future<int> getQRHistoryCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Helper method to convert Map to JSON string
  String _mapToJson(Map<String, dynamic> map) {
    // Simple JSON conversion - in a real app, you might want to use jsonEncode
    return map.toString();
  }

  // Helper method to convert JSON string to Map
  Map<String, dynamic> _jsonToMap(String jsonString) {
    // Simple JSON parsing - in a real app, you might want to use jsonDecode
    // This is a simplified version for demonstration
    try {
      // Remove the curly braces and split by comma
      final content = jsonString.substring(1, jsonString.length - 1);
      final pairs = content.split(', ');
      final map = <String, dynamic>{};
      
      for (final pair in pairs) {
        final colonIndex = pair.indexOf(':');
        if (colonIndex != -1) {
          final key = pair.substring(0, colonIndex).trim();
          final value = pair.substring(colonIndex + 1).trim();
          map[key] = value;
        }
      }
      
      return map;
    } catch (e) {
      return {};
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
