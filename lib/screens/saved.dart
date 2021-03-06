import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funny_facts/models/fact.dart';
import 'package:funny_facts/services/database.dart';
import 'package:funny_facts/widgets/fact_widget.dart';
import 'package:share_plus/share_plus.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final DatabaseClass databaseClass = DatabaseClass();

  List<Fact> factList = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _noSavedRecord = false;
  bool _endOfSaved = false;

  @override
  void initState() {
    initialLoadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return CircularProgressIndicator();
    }

    if (_noSavedRecord) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No saved facts"),
          TextButton(
              child: Text("Refresh"),
              onPressed: () {
                _noSavedRecord = false;
                initialLoadData();
              })
        ],
      );
    }

    return ListView.builder(
      itemCount: factList.length,
      itemBuilder: (BuildContext ctxt, int index) {
        if (index == factList.length - 1) {
          return Column(children: [
            FactWidget(
              isSaveScreen: true,
              fact: factList[index],
              index: index,
              onOptionPressed: actionPopUpItemSelected,
            ),
            bottomWidget()
          ]);
        }
        return FactWidget(
          isSaveScreen: true,
          fact: factList[index],
          index: index,
          onOptionPressed: actionPopUpItemSelected,
        );
      },
    );
  }

  Widget bottomWidget() {
    if (_loadingMore) {
      return CircularProgressIndicator();
    } else if (_endOfSaved) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
                child: Container(
              color: Colors.black26,
              width: 50.0,
              height: 1.0,
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0, 0, 2.0),
              child: Text("End"),
            ),
            Expanded(
                child: Container(
              width: 50.0,
              height: 1.0,
              color: Colors.black26,
            ))
          ],
        ),
      );
    } else {
      return TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
          primary: Colors.black54,
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          setState(() {
            _loadingMore = true;
          });

          var offset = factList[factList.length - 1].id;

          loadFact(offset, onFinish: () {
            setState(() {
              _loadingMore = false;
            });
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
          child: Text('Load More'),
        ),
      );
    }
  }

  Future<void> actionPopUpItemSelected(String value, int index) async {
    Fact fact = factList.elementAt(index);

    if (value == 'delete') {
      databaseClass.delete(fact);

      factList.removeAt(index);
      if (this.factList.length == 0) {
        _noSavedRecord = true;
      }

      //update UI
      setState(() {});

      Fluttertoast.showToast(
          msg: "Deleted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 16.0
      );

    } else if (value == 'share') {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(fact.text + "\n ---------------\n via Funny Facts App",
          subject: "Funny Fact from the Funny Fact App",
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  /// Loading fact from database
  Future<void> loadFact(int offset, {VoidCallback? onFinish}) async {
    var limit = 10;

    List<Map> maps = await databaseClass.select("facts", offset, limit);

    if (maps.length > 0) {
      List<Fact> factsFromDb = List.generate(maps.length, (i) {
        return Fact(
          identifier: maps[i]['_identifier'],
          text: maps[i]['_text'],
          id: maps[i]['id'],
        );
      });

      this.factList.addAll(factsFromDb);

      setState(() {});

      debugPrint("list length ${this.factList.length}");
    }

    if ((offset == -1 && maps.length == 0) ||
        this.factList.length == 0) // no saved records
    {
      _noSavedRecord = true;
    } else if (maps.length < limit || maps.length == 0) // no more records
    {
      _endOfSaved = true;
    }

    setState(() {});

    onFinish!();
  }

  /// Initial fetch for the database data
  Future initialLoadData() async {
    setState(() {
      _initialLoading = true;
    });

    debugPrint("save call before called");
    loadFact(-1, onFinish: () {
      debugPrint("save call after called");
      setState(() {
        _initialLoading = false;
      });
    });
  }
}
