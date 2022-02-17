
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DatabaseClass {

  static var _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var dbInstance = openDatabase(
      join(await getDatabasesPath(), 'funny_facts.db'),
      onCreate: _onCreate,
      version: 1,
    );
    return dbInstance;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE facts(id INTEGER PRIMARY KEY AUTOINCREMENT, _text TEXT, _identifier TEXT)");
    debugPrint("Tables is created");
  }

  //insertion
  Future<int> save(var model) async {
    var dbClient = await db;
    int res = await dbClient.insert(model.tableName, model.toMap());
    return res;
  }

  //deletion
  Future<int> delete(var model) async {
    var dbClient = await db;

    int res = await dbClient.delete(
      model.tableName,
      where: 'id = ?',
      whereArgs: [model.id],
    );

    return res;
  }

  //fetch
  Future<List<Map<String, dynamic>>> select(var tableName, int offset, int limit) async {
    var dbClient = await db;

    final List<Map<String, dynamic>> maps = await dbClient.rawQuery('SELECT * FROM $tableName WHERE id>? LIMIT $limit',[offset]);

    return maps;

  }
}
