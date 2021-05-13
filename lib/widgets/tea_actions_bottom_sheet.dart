import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:free_brew/tea.dart';

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
                return AlertDialog(
                  title: Text('Confirm Deletion'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('Are you sure you want to delete "${tea.name}?"'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        deleteCallback(tea);
                      },
                    ),
                    TextButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
