import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:useless_quotes/models/fact.dart';
import 'package:useless_quotes/services/api.dart';
import 'package:useless_quotes/widgets/fact_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void actionPopUpItemSelected(String value, int index) {
    if (value == 'save') {

      Fact toSave = factList.elementAt(index);
      toSave.insertFact();

      // Toast.show("Saved Successfully", context,
      //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

    } else if (value == 'share') {

    }
  }

  /**
   * Loading fact using API
   */
  Future<void> loadFact({VoidCallback? onFinish}) async {
    // 10 initial facts
    for (var i = 0; i < 10; i++) {
      try {
        Fact fact = await api.getFact();

        setState(() {
          this.factList.add(fact);
        });

        if (i == 9) {
          onFinish!();
        }
      } catch (e) {
        //couldn't fetch from api
        onFinish!();

        // Toast.show("Server Busy, try again later", context,
        //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }
  }

  /**
   * Initial fetch for the API data
   */
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
