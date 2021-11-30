// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infusion_timer/tea.dart';
import 'package:infusion_timer/widgets/preferences_page.dart';
import 'package:infusion_timer/widgets/tea_actions_bottom_sheet.dart';
import 'package:infusion_timer/widgets/tea_card.dart';
import 'package:infusion_timer/widgets/tea_input_dialog.dart';
import 'package:infusion_timer/widgets/timer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

const String TEAS_SAVE_KEY = "teas";

class CollectionPage extends StatefulWidget {
  CollectionPage({Key key}) : super(key: key);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<Tea> _teas = [];
  String _versionName = "";

  void _saveTeas() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        TEAS_SAVE_KEY, _teas.map((tea) => jsonEncode(tea)).toList());
  }

  @override
  void initState() {
    super.initState();
    PreferencesPage.loadSettings();
    SharedPreferences.getInstance().then((prefs) async {
      var savedTeaStrings = prefs.getStringList(TEAS_SAVE_KEY);
      if (savedTeaStrings == null) {
        var teasJsonString =
            (await rootBundle.loadString('assets/default_data.json'));
        var teasJson = json.decode(teasJsonString) as List;
        setState(() {
          _teas = teasJson.map((jsonTea) => Tea.fromJson(jsonTea)).toList();
        });
      } else {
        setState(() {
          _teas = savedTeaStrings
              .map((teaJson) => Tea.fromJson(jsonDecode(teaJson)))
              .toList();
        });
      }
    });
    PackageInfo.fromPlatform().then((value) => _versionName = value.version);
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
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.secondary),
              child: Text(
                "InfusionTimer",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Preferences"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PreferencesPage(
                            key: null,
                            savedCallback: () => {setState(() => {})})));
              },
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
              applicationVersion: _versionName,
              applicationLegalese:
                  "Copyright (c) 2021 Sesu8642\n\nhttps://github.com/Sesu8642/InfusionTimer",
              aboutBoxChildren: [
                Text(
                  "\nMany thanks to Mei Leaf (meileaf.com) for their permission to include data from their brewing guide!",
                  style: TextStyle(fontSize: 14),
                )
              ],
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
                  },
              PreferencesPage.teaVesselSizeMlPref);
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
