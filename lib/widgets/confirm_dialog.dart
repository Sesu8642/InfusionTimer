// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String confirmText;
  final Function() okCallback;
  final Function() cancelCallback;

  ConfirmDialog(
      this.title, this.confirmText, this.okCallback, this.cancelCallback);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(confirmText),
          ],
        ),
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () => cancelCallback(),
          child: const Text('Cancel'),
        ),
        new TextButton(
          onPressed: () => okCallback(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
