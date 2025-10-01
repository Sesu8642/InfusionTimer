// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infusion_timer/tea.dart';
import 'package:infusion_timer/widgets/star_rating_form_field.dart';

class TeaInputDialog extends StatefulWidget {
  final Tea tea;
  final Function(Tea) saveCallback;
  final Function(Tea) cancelCallback;

  const TeaInputDialog(
    this.tea,
    this.saveCallback,
    this.cancelCallback, {
    super.key,
  });

  @override
  TeaInputFormFormState createState() {
    return TeaInputFormFormState();
  }
}

class TeaInputFormFormState extends State<TeaInputDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController newInfusionController = TextEditingController();

  _addInfusion() {
    setState(() {
      int? parsedInt = int.tryParse(newInfusionController.text);
      if (parsedInt != null) {
        widget.tea.infusions.add(Infusion(parsedInt));
      }
    });
    newInfusionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Tea'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  const Text("Rating "),
                  StarRatingFormField(
                    initialValue: widget.tea.rating ?? 0,
                    onSaved: (value) {
                      widget.tea.rating = value == 0 ? null : value;
                    },
                  ),
                ],
              ),
              TextFormField(
                initialValue: widget.tea.name,
                decoration: const InputDecoration(hintText: 'Name'),
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
                  num? parsed = num.tryParse(value?.replaceAll(',', '.') ?? '');
                  if (parsed == null) {
                    return "Invalid Amount";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Amount in g/100ml',
                ),
                onSaved: (value) {
                  widget.tea.gPer100Ml = double.parse(
                    value?.replaceAll(',', '.') ?? '',
                  );
                },
              ),
              TextFormField(
                initialValue: widget.tea.subtitle,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Subtitle'),
                onSaved: (value) {
                  widget.tea.subtitle = value ?? "";
                },
              ),
              Text(
                "\nInfusions",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ...widget.tea.infusions.map(
                (infusion) => ListTile(
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    splashRadius: Material.defaultSplashRadius / 1.5,
                    tooltip: 'delete',
                    onPressed: () {
                      setState(() {
                        widget.tea.infusions.removeAt(
                          widget.tea.infusions.indexOf(infusion),
                        );
                      });
                    },
                  ),
                  title: Text(
                    "${widget.tea.infusions.indexOf(infusion) + 1}.   ${infusion.duration}s",
                  ),
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
                validator: (value) {
                  if (widget.tea.infusions.isEmpty) {
                    return "Add at least one infusion";
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            widget.cancelCallback(widget.tea);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _addInfusion();
            setState(() {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.saveCallback(widget.tea);
              }
            });
          },
          child: const Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
