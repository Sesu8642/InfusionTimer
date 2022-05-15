// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:infusion_timer/tea.dart';
import 'package:infusion_timer/widgets/confirm_dialog.dart';

class TeaActionsBottomSheet extends StatelessWidget {
  final Tea tea;
  final Function(Tea) editCallback;
  final Function(Tea) deleteCallback;

  TeaActionsBottomSheet(this.tea, this.editCallback, this.deleteCallback);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        ListTile(
            leading: Icon(Icons.edit),
            title: Text("Edit"),
            onTap: () => editCallback(tea)),
        ListTile(
          leading: Icon(Icons.delete),
          title: Text("Delete"),
          onTap: () {
            return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return ConfirmDialog("Are you sure?",
                    '"${tea.name}" will be deleted permanently.', () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  deleteCallback(tea);
                }, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
              },
            );
          },
        ),
      ],
    );
  }
}
