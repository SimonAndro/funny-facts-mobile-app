import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:funny_facts/models/fact.dart';
import 'package:funny_facts/services/api.dart';
import 'package:funny_facts/services/database.dart';
import 'package:funny_facts/widgets/fact_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/notification.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final DatabaseClass databaseClass = DatabaseClass();

  final ApiService api = ApiService();

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
          const Text("Loading failed, check internet connection or try again later"),
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

                      loadFact(onFinish: () {
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

  Future<void> actionPopUpItemSelected(String value, int index) async {

    Fact fact = factList.elementAt(index);

    if (value == 'save') {

      databaseClass.save(fact);

      Fluttertoast.showToast(
          msg: "Saved Successfully",
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

  /// Loading fact using API
  Future<void> loadFact({VoidCallback? onFinish}) async {
    // 10 initial facts
    for (var i = 0; i < 10; i++) {
      try {
        Fact fact = await api.getFact();

        setState(() {
          factList.add(fact);
        });

        if (i == 9) {
          onFinish!();
        }
      } catch (e) {
        debugPrint(e.toString());
        //couldn't fetch from api
        onFinish!();
      }
    }
  }

  /// Initial fetch for the API data
  Future initialLoadData() async {
    setState(() {
      _initialLoading = true;
    });

    debugPrint("call before called");
    loadFact(onFinish: () {
      debugPrint("call after called");
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
