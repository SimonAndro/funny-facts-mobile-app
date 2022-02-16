import 'package:sqflite/sqflite.dart';
import 'package:useless_quotes/services/database.dart';

class Fact{
  final int id;
  final String identifier;
  final String text;

  Fact({required this.identifier, required this.id, required this.text});

  factory Fact.fromJson(Map<String, dynamic> json){
    return Fact(id:-1, text: json['text'], identifier: json['id']);
  }

  Map<String, dynamic> toMap() {
    return {
      '_text': text,
      '_identifier':identifier
    };
  }

  @override
  String toString() {
    return 'Fact{id: $id, text: $text, identifier: $identifier}';
  }

  Future<void> insertFact() async {
    // Get a reference to the database.
    final db = await DatabaseClass.getdbInstance();

    await db.insert(
      'facts',
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFact(String id) async {
    // Get a reference to the database.
    final db = await DatabaseClass.getdbInstance();

    // Remove the Dog from the database.
    await db.delete(
      'facts',
      // Use a `where` clause to delete a specific fact.
      where: 'id = ?',
      // Pass the fact's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  // A method that retrieves all the Facts from the facts table.
  static Future<List<Fact>> Factsfromdb(int offset, int limit) async {
    // Get a reference to the database.
    final db = await DatabaseClass.getdbInstance();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM facts WHERE id>? LIMIT $limit',[offset]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Fact(
        identifier: maps[i]['_identifier'],
        text: maps[i]['_text'],
        id: maps[i]['id'],
      );
    });
  }

}