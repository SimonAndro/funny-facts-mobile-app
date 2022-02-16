import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:useless_quotes/models/fact.dart';
import 'package:useless_quotes/widgets/fact_widget.dart';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Fact> factList = [];

  bool _initialLoading = true;
  bool _loadingFailed = false;
  bool _loadingMore = false;

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

    if (_loadingFailed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Loading failed, try again later"),
          TextButton(child: Text("Try again"), onPressed: initialLoadData)
        ],
      );
    }

    return ListView.builder(
      itemCount: factList.length,
      itemBuilder: (BuildContext ctxt, int index) {
        if (index == factList.length - 1) {
          return Column(children: [
            FactWidget(
              fact: factList[index],
              index: index,
              onOptionPressed: actionPopUpItemSelected,
            ),
            _loadingMore
                ? CircularProgressIndicator()
                : TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                      primary: Colors.black54,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {

                      setState(() {
                        _loadingMore = true;
                      });

                      var offset =  factList[factList.length - 1].id;

                      loadFact(offset,onFinish: () {
                        setState(() {
                          _loadingMore = false;
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
                      child: Text('Load More'),
                    ),
                  )
          ]);
        }
        return FactWidget(
          fact: factList[index],
          index: index,
          onOptionPressed: actionPopUpItemSelected,
        );
      },
    );
  }

  void actionPopUpItemSelected(String value, int index) {
    if (value == 'delete') {
      Fact toSave = factList.elementAt(index);
      toSave.insertFact();

      // Toast.show("Saved Successfully", context,
      //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

    } else if (value == 'share') {}
  }

  /// Loading fact from database
  Future<void> loadFact(int offset,{VoidCallback? onFinish}) async {

    var limit = 10;
    List<Fact> factsFromDb = await Fact.Factsfromdb(offset, limit);

    setState(() {
      this.factList.addAll(factsFromDb);
    });

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

        if (factList.length == 0) {
          _loadingFailed = true;
        } else {
          _loadingFailed = false;
        }
      });
    });
  }
}
