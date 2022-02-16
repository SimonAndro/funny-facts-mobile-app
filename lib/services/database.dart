import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseClass {

  static getdbInstance() async {
    var dbInstance = openDatabase(
      join(await getDatabasesPath(), 'funny_facts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE facts(id INTEGER PRIMARY KEY AUTOINCREMENT, _text TEXT, _identifier TEXT)',
        );
      },
      version: 1,
    );
    return dbInstance;
  }

}
