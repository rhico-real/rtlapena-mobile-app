import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_report.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'daily_reports.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_reports(
        id TEXT PRIMARY KEY,
        report_date TEXT NOT NULL,
        unit_type TEXT NOT NULL,
        contractor_name TEXT NOT NULL,
        block_number TEXT NOT NULL,
        lot_number TEXT NOT NULL,
        weather_log TEXT NOT NULL,
        work_log TEXT NOT NULL,
        issue_photos TEXT NOT NULL,
        personnel_count INTEGER NOT NULL,
        issues TEXT NOT NULL,
        safety_notes TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<String> saveReport(DailyReport report) async {
    final db = await database;
    final id = report.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    final reportData = {
      'id': id,
      'report_date': report.reportDate,
      'unit_type': report.unitType,
      'contractor_name': report.contractorName,
      'block_number': report.blockNumber,
      'lot_number': report.lotNumber,
      'weather_log': jsonEncode(report.weatherLog.map((w) => w.toJson()).toList()),
      'work_log': jsonEncode(report.workLog.map((w) => w.toJson()).toList()),
      'issue_photos': jsonEncode(report.issuePhotos.map((i) => i.toJson()).toList()),
      'personnel_count': report.personnelCount,
      'issues': report.issues,
      'safety_notes': report.safetyNotes,
      'timestamp': report.timestamp.toIso8601String(),
    };

    await db.insert(
      'daily_reports',
      reportData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<List<DailyReport>> getAllReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_reports',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return DailyReport(
        id: maps[i]['id'],
        reportDate: maps[i]['report_date'],
        unitType: maps[i]['unit_type'],
        contractorName: maps[i]['contractor_name'],
        blockNumber: maps[i]['block_number'],
        lotNumber: maps[i]['lot_number'],
        weatherLog: (jsonDecode(maps[i]['weather_log']) as List)
            .map((w) => WeatherEntry.fromJson(w))
            .toList(),
        workLog: (jsonDecode(maps[i]['work_log']) as List)
            .map((w) => WorkEntry.fromJson(w))
            .toList(),
        issuePhotos: (jsonDecode(maps[i]['issue_photos']) as List)
            .map((i) => IssuePhoto.fromJson(i))
            .toList(),
        personnelCount: maps[i]['personnel_count'],
        issues: maps[i]['issues'],
        safetyNotes: maps[i]['safety_notes'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
      );
    });
  }

  Future<DailyReport?> getReport(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return DailyReport(
        id: map['id'],
        reportDate: map['report_date'],
        unitType: map['unit_type'],
        contractorName: map['contractor_name'],
        blockNumber: map['block_number'],
        lotNumber: map['lot_number'],
        weatherLog: (jsonDecode(map['weather_log']) as List)
            .map((w) => WeatherEntry.fromJson(w))
            .toList(),
        workLog: (jsonDecode(map['work_log']) as List)
            .map((w) => WorkEntry.fromJson(w))
            .toList(),
        issuePhotos: (jsonDecode(map['issue_photos']) as List)
            .map((i) => IssuePhoto.fromJson(i))
            .toList(),
        personnelCount: map['personnel_count'],
        issues: map['issues'],
        safetyNotes: map['safety_notes'],
        timestamp: DateTime.parse(map['timestamp']),
      );
    }
    return null;
  }

  Future<void> deleteReport(String id) async {
    final db = await database;
    await db.delete(
      'daily_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
