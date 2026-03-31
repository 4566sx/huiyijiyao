import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meeting.dart';
import '../models/ai_config.dart';

class StorageService {
  static Database? _database;
  static const String _dbName = 'meetings.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meetings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT,
            transcript TEXT DEFAULT '',
            minutes TEXT DEFAULT '',
            audioPath TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMeeting(Meeting meeting) async {
    final db = await database;
    return await db.insert('meetings', meeting.toMap());
  }

  Future<int> updateMeeting(Meeting meeting) async {
    final db = await database;
    return await db.update(
      'meetings',
      meeting.toMap(),
      where: 'id = ?',
      whereArgs: [meeting.id],
    );
  }

  Future<int> deleteMeeting(int id) async {
    final db = await database;
    return await db.delete(
      'meetings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Meeting>> getMeetings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meetings',
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => Meeting.fromMap(maps[i]));
  }

  Future<Meeting?> getMeeting(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meetings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Meeting.fromMap(maps.first);
  }

  Future<void> saveAiConfig(AiConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_config', jsonEncode(config.toMap()));
  }

  Future<AiConfig?> loadAiConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('ai_config');
    if (data == null) return null;
    return AiConfig.fromMap(jsonDecode(data));
  }

  Future<void> saveSelectedModelType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_model_type', type);
  }

  Future<String> loadSelectedModelType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_model_type') ?? 'openai';
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('meetings');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
