// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infusion_timer/persistence_service.dart';
import 'package:infusion_timer/widgets/data_backup_dialog.dart';
import 'package:infusion_timer/widgets/data_restore_dialog.dart';

class PreferencesPage extends StatefulWidget {
  PreferencesPage({Key key}) : super(key: key);

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _vesselSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _vesselSizeController.value = TextEditingValue(
          text: PersistenceService.teaVesselSizeMlPref.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preferences")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Size of your tea brewing vessel in ml",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextFormField(
                  controller: _vesselSizeController,
                  decoration: InputDecoration(icon: Icon(Icons.free_breakfast)),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a value";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) async {
                    if (_formKey.currentState.validate()) {
                      await PersistenceService.setTeaVesselSizeMlPref(
                          int.parse(value));
                    }
                  },
                ),
                Text(
                  "Data backup/restore",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                new DataBackupDialog(),
                          );
                        },
                        child: Text("Data Backup"))),
                ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) =>
                            new DataRestoreDialog(),
                      );
                      setState(() {});
                    },
                    child: Text("Data Restore")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
