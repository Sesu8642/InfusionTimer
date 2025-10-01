// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infusion_timer/persistence_service.dart';
import 'package:infusion_timer/widgets/data_backup_dialog.dart';
import 'package:infusion_timer/widgets/data_restore_dialog.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  PreferencesPageState createState() => PreferencesPageState();
}

class PreferencesPageState extends State<PreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vesselSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _vesselSizeController.value = TextEditingValue(
        text: PersistenceService.teaVesselSizeMlPref.toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferences")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Size of your tea brewing vessel in ml",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextFormField(
                  controller: _vesselSizeController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.free_breakfast),
                  ),
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
                    if (_formKey.currentState!.validate()) {
                      await PersistenceService.setTeaVesselSizeMlPref(
                        int.parse(value),
                      );
                    }
                  },
                ),
                const Text(
                  "Data backup/restore",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) =>
                            const DataBackupDialog(),
                      );
                    },
                    child: const Text("Data Backup"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => DataRestoreDialog(),
                    );
                    setState(() {
                      _vesselSizeController.value = TextEditingValue(
                        text: PersistenceService.teaVesselSizeMlPref.toString(),
                      );
                    });
                  },
                  child: const Text("Data Restore"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
