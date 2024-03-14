// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:infusion_timer/persistence_service.dart';
import 'package:flutter/material.dart';
import 'package:infusion_timer/tea.dart';

class NotesPage extends StatefulWidget {
  final Tea tea;

  const NotesPage({Key? key, required this.tea}) : super(key: key);

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hasUnsavedChanges = false;
  Future<void> _onPopInvoked(bool didPop) async {
    // confirm cancelling infusion if going back to collection page
    if (didPop) {
      return;
    }
    final int? action = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save unsaved changes?'),
          content: const Text('You have unsaved changes.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: const Text('Save and Close'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 1),
              child: const Text('Discard and Close'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 2),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    switch (action) {
      case 0:
        _formKey.currentState!.save();
        PersistenceService.updateTea(widget.tea);
        if (context.mounted) {
          Navigator.pop(context);
        }
        break;
      case 1:
        if (context.mounted) {
          Navigator.pop(context);
        }
        break;
      case 2:
        // nothing to do
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Notes"),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Center(child: Text(widget.tea.name!)),
                      ),
                      Expanded(
                        child: TextFormField(
                          minLines: 15,
                          initialValue: widget.tea.detailedNotes,
                          maxLines: null,
                          // using collapsed to hide black line on the bottom
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Enter your notes here',
                          ),
                          onChanged: (value) {
                            setState(() => _hasUnsavedChanges = true);
                          },
                          onSaved: (value) {
                            widget.tea.detailedNotes = value;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () {
                          _formKey.currentState!.save();
                          PersistenceService.updateTea(widget.tea);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save and Close',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
