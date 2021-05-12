import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:free_brew/tea.dart';
import 'package:free_brew/tea_input_form.dart';
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ..._teas.map((tea) => ListTile(
                leading: Icon(Icons.map),
                title: Text(jsonEncode(tea)),
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => new TeaInputDialog((tea) => {
                    setState(() {
                      _teas.add(tea);
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setStringList(TEAS_SAVE_KEY,
                            _teas.map((tea) => jsonEncode(tea)).toList());
                      });
                    })
                  }));
        },
        tooltip: 'Add Tea',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
