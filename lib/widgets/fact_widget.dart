import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:funny_facts/models/fact.dart';

class FactWidget extends StatelessWidget {
  const FactWidget(
      {this.onOptionPressed,
      Key? key,
      required this.fact,
      required this.index,
      this.isSaveScreen = false})
      : super(key: key);

  final bool isSaveScreen;
  final Fact fact;
  final int index;
  final Function? onOptionPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(fact.text),
          )),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                isSaveScreen
                    ? PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete,color: Colors.red.shade200,),
                            Text("delete"),
                          ],
                        ),
                      )
                    : PopupMenuItem(
                        value: "save",
                        child: Row(
                          children: [
                            Icon(Icons.save,color: Colors.blue),
                            Text("Save"),
                          ],
                        ),
                      ),
                PopupMenuItem(
                  value: "share",
                  child: Row(
                    children: [
                      Icon(Icons.share,color: Colors.green),
                      Text("Share"),
                    ],
                  ),
                )
              ];
            },
            onSelected: (String value) => onOptionPressed!(value, index),
          )
        ],
      ),
    );
  }
}
