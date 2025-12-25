// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infusion_timer/tea.dart';
import 'package:infusion_timer/widgets/star_rating_form_field.dart';

class TeaInputPage extends StatefulWidget {
  final Tea tea;
  final Function(Tea) saveCallback;

  const TeaInputPage({
    super.key,
    required this.tea,
    required this.saveCallback,
  });

  @override
  TeaInputPageState createState() => TeaInputPageState();
}

class TeaInputPageState extends State<TeaInputPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hasUnsavedChanges = false;
  late final _infusions = List.of(widget.tea.infusions);

  TextEditingController newInfusionController = TextEditingController();

  _addInfusion() {
    setState(() {
      int? parsedInt = int.tryParse(newInfusionController.text);
      if (parsedInt != null) {
        _infusions.add(Infusion(parsedInt));
      }
    });
    newInfusionController.clear();
  }

  void validateAndSave() {
    _addInfusion();
    setState(() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        widget.tea.infusions = _infusions;
        Navigator.pop(context);
        widget.saveCallback(widget.tea);
      }
    });
  }

  Future<void> _onPopInvoked(bool didPop, dynamic result) async {
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
        validateAndSave();
        break;
      case 1:
        Navigator.pop(context);
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
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Tea")),
        body: Form(
          onChanged: () {
            setState(() {
              _hasUnsavedChanges = true;
            });
          },
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Rating", style: Theme.of(context).textTheme.titleLarge),
                  StarRatingFormField(
                    initialValue: widget.tea.rating ?? 0,
                    onSaved: (value) {
                      widget.tea.rating = value == 0 ? null : value;
                    },
                  ),
                  Text("\nName", style: Theme.of(context).textTheme.titleLarge),
                  TextFormField(
                    initialValue: widget.tea.name,
                    decoration: const InputDecoration(hintText: 'Name'),
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter a name";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      widget.tea.name = value!;
                    },
                  ),
                  Text(
                    "\nBrewing Temperature in °C",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextFormField(
                    initialValue: widget.tea.temperature == null
                        ? ""
                        : widget.tea.temperature.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter the brewing temperature";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      widget.tea.temperature = int.parse(value!);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Brewing Temperature in °C',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "\nAmount in g/100ml",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextFormField(
                    initialValue: widget.tea.gPer100Ml == null
                        ? ""
                        : widget.tea.gPer100Ml.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9,.]')),
                    ],
                    validator: (value) {
                      num? parsed = num.tryParse(
                        value?.replaceAll(',', '.') ?? '',
                      );
                      if (parsed == null) {
                        return "Invalid Amount";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Amount in g/100ml',
                    ),
                    textAlign: TextAlign.center,
                    onSaved: (value) {
                      widget.tea.gPer100Ml = double.parse(
                        value?.replaceAll(',', '.') ?? '',
                      );
                    },
                  ),
                  Text(
                    "\nSubtitle",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextFormField(
                    initialValue: widget.tea.subtitle,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(hintText: 'Subtitle'),
                    textAlign: TextAlign.center,
                    onSaved: (value) {
                      widget.tea.subtitle = value ?? "";
                    },
                  ),
                  Text(
                    "\nInfusions",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ..._infusions.map(
                    (infusion) => ListTile(
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        splashRadius: Material.defaultSplashRadius / 1.5,
                        tooltip: 'delete',
                        onPressed: () {
                          setState(() {
                            _hasUnsavedChanges = true;
                            _infusions.removeAt(_infusions.indexOf(infusion));
                          });
                        },
                      ),
                      title: Text(
                        "${_infusions.indexOf(infusion) + 1}.   ${infusion.duration}s",
                      ),
                      titleAlignment: ListTileTitleAlignment.center,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                  ),
                  TextFormField(
                    controller: newInfusionController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Infusion time in s',
                      suffixIcon: IconButton(
                        splashRadius: Material.defaultSplashRadius / 1.5,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _addInfusion();
                        },
                      ),
                    ),
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (_infusions.isEmpty) {
                        return "Add at least one infusion";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: OverflowBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      spacing: 8,
                      children: <Widget>[
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            validateAndSave();
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
