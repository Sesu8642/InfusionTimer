// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infusion_timer/backup_data.dart';
import 'package:infusion_timer/persistence_service.dart';
import 'package:infusion_timer/widgets/confirm_dialog.dart';

class DataRestoreDialog extends StatelessWidget {
  final TextEditingController textController = TextEditingController();

  DataRestoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Paste the backed up text here.'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: textController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () async => textController.text =
                    (await Clipboard.getData("text/plain"))?.text ?? "",
                child: const Text('Paste from clipboard'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => ConfirmDialog(
              "Are you sure?",
              "Your current tea collection will be lost and replaced by the backup.",
              () {
                Navigator.of(context).pop();
                try {
                  var backup = BackupData.fromJson(
                    jsonDecode(textController.text),
                  );
                  PersistenceService.restoreFomBackup(backup)
                      .then((value) => Navigator.of(context).pop())
                      .onError(
                        (e, stackTrace) => ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString()))),
                      );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              () => Navigator.of(context).pop(),
            ),
          ),
          child: const Text('Restore'),
        ),
      ],
    );
  }
}
