import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inspection.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // ========================
  // DATABASE INITIALIZATION
  // ========================
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inspection.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // ========================
  // TABLE CREATION
  // ========================
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tbl_inspections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        property_name TEXT,
        description TEXT,
        rating TEXT,
        latitude REAL,
        longitude REAL,
        date_created TEXT,
        photos TEXT
      )
    ''');
  }

  // ========================
  // INSERT INSPECTION
  // ========================
  Future<int> insertInspection(Inspection inspection) async {
    final db = await database;
    return await db.insert('tbl_inspections', inspection.toMap());
  }

  // ========================
  // GET ALL INSPECTIONS
  // ========================
  Future<List<Inspection>> getInspections() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'tbl_inspections',
      orderBy: 'id DESC',
    );

    return result.map((e) => Inspection.fromMap(e)).toList();
  }

  // ========================
  // DELETE INSPECTION
  // ========================
  Future<int> deleteInspection(int id) async {
    final db = await database;
    return await db.delete('tbl_inspections', where: 'id = ?', whereArgs: [id]);
  }

  // ========================
  // UPDATE INSPECTION
  // ========================
  Future<int> updateInspection(Inspection inspection) async {
    final db = await database;
    return await db.update(
      'tbl_inspections',
      inspection.toMap(),
      where: 'id = ?',
      whereArgs: [inspection.id],
    );
  }
}
