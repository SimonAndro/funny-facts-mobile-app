
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:useless_quotes/models/fact.dart';

class FactWidget extends StatelessWidget {
  const FactWidget({this.onOptionPressed,
    Key? key, required this.fact, required this.index,
  }) : super(key: key);

  final Fact fact;
  final int index;
  final Function? onOptionPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(fact.text),
          )),
           PopupMenuButton(
            itemBuilder:(context){
              return [
                PopupMenuItem(
                  value: "save",
                  child: Row(
                    children: [
                      Icon(Icons.save),
                      Text("Save"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "share",
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      Text("Share"),
                    ],
                  ),
                )
              ];
            },
            onSelected: (String value)=>onOptionPressed!(value,index),
          )
        ],
      ),
    );
  }
}