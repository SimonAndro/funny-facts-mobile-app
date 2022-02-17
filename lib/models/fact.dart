
import 'dart:convert';

class Fact{
  final String tableName = "facts";
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

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Fact{id: $id, text: $text, identifier: $identifier}';
  }

}