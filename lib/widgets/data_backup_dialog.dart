// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infusion_timer/persistence_service.dart';

class DataBackupDialog extends StatelessWidget {
  DataBackupDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Copy this text and store it somewhere safe.'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              initialValue: jsonEncode(PersistenceService.getBackupData()),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              readOnly: true,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: new TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text: jsonEncode(PersistenceService.getBackupData())));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Copied to clipboard."),
                  ));
                },
                child: const Text('Copy to clipboard'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
