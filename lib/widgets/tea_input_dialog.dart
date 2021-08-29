import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infusion_timer/tea.dart';

class TeaInputDialog extends StatefulWidget {
  final Tea tea;
  final Function(Tea) saveCallback;
  final Function(Tea) cancelCallback;

  TeaInputDialog(this.tea, this.saveCallback, this.cancelCallback);

  @override
  TeaInputFormFormState createState() {
    return TeaInputFormFormState();
  }
}

class TeaInputFormFormState extends State<TeaInputDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController newInfusionController = TextEditingController();

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
              TextFormField(
                initialValue: widget.tea.name,
                decoration: InputDecoration(hintText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a name";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  widget.tea.name = value;
                },
              ),
              TextFormField(
                initialValue: widget.tea.temperature == null
                    ? ""
                    : widget.tea.temperature.toString(),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter the brewing temperature";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  widget.tea.temperature = int.parse(value);
                },
                decoration: InputDecoration(
                  hintText: 'Brewing Temperature in °C',
                ),
              ),
              TextFormField(
                initialValue: widget.tea.gPer100Ml == null
                    ? ""
                    : widget.tea.gPer100Ml.toString(),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                validator: (value) {
                  num parsed = num.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null) {
                    return "Invalid Amount";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Amount in g/100ml',
                ),
                onSaved: (value) {
                  widget.tea.gPer100Ml =
                      double.parse(value.replaceAll(',', '.'));
                },
              ),
              TextFormField(
                initialValue: widget.tea.notes,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Notes',
                ),
                onSaved: (value) {
                  widget.tea.notes = value;
                },
              ),
              Text(
                "\nInfusions",
                style: Theme.of(context).textTheme.headline6,
              ),
              ...widget.tea.infusions.map(
                (infusion) => ListTile(
                  trailing: IconButton(
                      icon: Icon(Icons.delete),
                      splashRadius: Material.defaultSplashRadius / 1.5,
                      tooltip: 'delete',
                      onPressed: () {
                        setState(() {
                          widget.tea.infusions
                              .removeAt(widget.tea.infusions.indexOf(infusion));
                        });
                      }),
                  title: Text(
                      (widget.tea.infusions.indexOf(infusion) + 1).toString() +
                          ".   " +
                          infusion.duration.toString() +
                          "s"),
                  contentPadding: EdgeInsets.all(0),
                ),
              ),
              Row(
                children: [],
              ),
              TextFormField(
                controller: newInfusionController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Infusion time in s',
                  suffixIcon: IconButton(
                    splashRadius: Material.defaultSplashRadius / 1.5,
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        int parsedInt =
                            int.tryParse(newInfusionController.text);
                        if (parsedInt != null) {
                          widget.tea.infusions.add(new Infusion(parsedInt));
                        }
                      });
                      newInfusionController.clear();
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
        new TextButton(
          onPressed: () {
            setState(() {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                widget.saveCallback(widget.tea);
              }
            });
          },
          child: const Text('Save'),
        ),
        new TextButton(
          onPressed: () {
            widget.cancelCallback(widget.tea);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
