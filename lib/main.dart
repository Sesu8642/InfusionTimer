import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:free_brew/tea.dart';
import 'package:free_brew/widgets/tea_actions_bottom_sheet.dart';
import 'package:free_brew/widgets/tea_card.dart';
import 'package:free_brew/widgets/tea_input_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String TEAS_SAVE_KEY = "teas";

void main() async {
  runApp(FreeBrew());
}

class FreeBrew extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<FreeBrew> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeBrew',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CollectionPage(title: 'Tea Collection'),
    );
  }
}

class CollectionPage extends StatefulWidget {
  CollectionPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<Tea> _teas = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _teas = prefs
            .getStringList(TEAS_SAVE_KEY)
            .map((teaJson) => Tea.fromJson(jsonDecode(teaJson)))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _teas.length,
        itemBuilder: (context, i) {
          return TeaCard(
              _teas[i],
              (tea) => {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) =>
                            new TeaActionsBottomSheet(
                                tea,
                                (tea) => {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            new TeaInputDialog(
                                          tea,
                                          (tea) => {
                                            setState(
                                              () {
                                                SharedPreferences.getInstance()
                                                    .then(
                                                  (prefs) {
                                                    prefs.setStringList(
                                                        TEAS_SAVE_KEY,
                                                        _teas
                                                            .map((tea) =>
                                                                jsonEncode(tea))
                                                            .toList());
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              },
                                            )
                                          },
                                        ),
                                      )
                                    }, (tea) {
                              setState(() {
                                _teas.remove(tea);
                                SharedPreferences.getInstance().then(
                                  (prefs) {
                                    prefs.setStringList(
                                        TEAS_SAVE_KEY,
                                        _teas
                                            .map((tea) => jsonEncode(tea))
                                            .toList());
                                  },
                                );
                              });
                            }))
                  });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => new TeaInputDialog(
              new Tea(null, null, null, [], null),
              (tea) => {
                setState(
                  () {
                    _teas.add(tea);
                    SharedPreferences.getInstance().then(
                      (prefs) {
                        prefs.setStringList(TEAS_SAVE_KEY,
                            _teas.map((tea) => jsonEncode(tea)).toList());
                      },
                    );
                  },
                )
              },
            ),
          );
        },
        tooltip: 'Add Tea',
        child: Icon(Icons.add),
      ),
    );
  }
}
