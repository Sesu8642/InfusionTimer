import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:free_brew/tea.dart';
import 'package:free_brew/widgets/tea_actions_bottom_sheet.dart';
import 'package:free_brew/widgets/tea_card.dart';
import 'package:free_brew/widgets/tea_input_dialog.dart';
import 'package:free_brew/widgets/timer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String TEAS_SAVE_KEY = "teas";
List<Tea> DEFAULT_TEAS = [
  new Tea("Generic White Tea", 85, 0.6, [new Infusion(180), new Infusion(240)],
      "test"),
  new Tea("Generic Green Tea", 80, 0.5, [new Infusion(120), new Infusion(180)],
      "test"),
  new Tea("Generic Yellow Tea", 85, 0.6, [new Infusion(120), new Infusion(180)],
      "test"),
  new Tea(
      "Generic Oolong Tea (strip)",
      99,
      0.8,
      [
        new Infusion(120),
        new Infusion(150),
        new Infusion(180),
        new Infusion(210)
      ],
      "test"),
  new Tea(
      "Generic Oolong Tea (ball)",
      99,
      1.0,
      [
        new Infusion(120),
        new Infusion(150),
        new Infusion(180),
        new Infusion(210),
        new Infusion(240)
      ],
      "test"),
  new Tea(
      "Generic Black Tea (small leaf)",
      90,
      0.8,
      [
        new Infusion(120),
        new Infusion(180),
        new Infusion(240),
        new Infusion(320)
      ],
      "test"),
  new Tea(
      "Generic Black Tea (large leaf)",
      95,
      0.7,
      [
        new Infusion(120),
        new Infusion(180),
        new Infusion(240),
        new Infusion(320)
      ],
      "test"),
  new Tea(
      "Generic PuErh Tea (raw)",
      95,
      0.9,
      [
        new Infusion(120),
        new Infusion(150),
        new Infusion(180),
        new Infusion(210),
        new Infusion(240),
        new Infusion(270)
      ],
      "test"),
  new Tea(
      "Generic PuErh Tea (ripe)",
      99,
      0.9,
      [
        new Infusion(120),
        new Infusion(150),
        new Infusion(180),
        new Infusion(210),
        new Infusion(240),
        new Infusion(270)
      ],
      "test")
];

class CollectionPage extends StatefulWidget {
  CollectionPage({Key key}) : super(key: key);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<Tea> _teas = [];

  void _saveTeas() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        TEAS_SAVE_KEY, _teas.map((tea) => jsonEncode(tea)).toList());
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        var saved_tea_strings = prefs.getStringList(TEAS_SAVE_KEY);
        if (saved_tea_strings == null) {
          _teas = DEFAULT_TEAS;
        } else {
          _teas = saved_tea_strings
              .map((teaJson) => Tea.fromJson(jsonDecode(teaJson)))
              .toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tea Collection")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
              child: Text(
                "FreeBrew",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            AboutListTile(
              icon: Icon(Icons.favorite),
              applicationIcon: Container(
                height: IconTheme.of(context).resolve(context).size,
                width: IconTheme.of(context).resolve(context).size,
                child: Image.asset(
                  "assets/icon_simple.png",
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              applicationVersion:
                  "1.0.0", // TODO: at least take this from some contant or whatever
              applicationLegalese: "Copyright (c) 2021 Sesu8642",
            )
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _teas.length,
        itemBuilder: (context, i) {
          return TeaCard(_teas[i], (tea) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimerPage(tea: tea)),
            );
            setState(
              () {
                // bring tea to the first position
                _teas.remove(tea);
                _teas.insert(0, tea);
                _saveTeas();
              },
            );
          },
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
                                                _saveTeas();
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          },
                                          (tea) {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      )
                                    }, (tea) {
                              setState(() {
                                _teas.remove(tea);
                                _saveTeas();
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
              (tea) {
                setState(
                  () {
                    _teas.insert(0, tea);
                    _saveTeas();
                  },
                );
                Navigator.of(context).pop();
              },
              (tea) {
                Navigator.of(context).pop();
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
