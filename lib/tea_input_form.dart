import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_brew/tea.dart';

class TeaInputDialog extends StatefulWidget {
  final Function(Tea) saveCallback;

  TeaInputDialog(this.saveCallback);

  @override
  TeaInputFormFormState createState() {
    return TeaInputFormFormState();
  }
}

class TeaInputFormFormState extends State<TeaInputDialog> {
  final _formKey = GlobalKey<FormState>();

  Tea result = new Tea(null, null, null, [], "");
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
                decoration: InputDecoration(hintText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a name";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  result.name = value;
                },
              ),
              TextFormField(
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
                  result.temperature = int.parse(value);
                },
                decoration: InputDecoration(
                  hintText: 'Brewing Temperature in °C',
                ),
              ),
              TextFormField(
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
                  result.gPer100Ml = double.parse(value);
                },
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Notes',
                ),
                onSaved: (value) {
                  result.notes = value;
                },
              ),
              Text(
                "\nInfusions",
                style: Theme.of(context).textTheme.headline6,
              ),
              ...result.infusions.map(
                (infusion) => ListTile(
                  trailing: IconButton(
                      icon: Icon(Icons.delete),
                      splashRadius: Material.defaultSplashRadius / 1.5,
                      tooltip: 'delete',
                      onPressed: () {
                        setState(() {
                          result.infusions
                              .removeAt(result.infusions.indexOf(infusion));
                        });
                      }),
                  title: Text(
                      (result.infusions.indexOf(infusion) + 1).toString() +
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
                          result.infusions.add(new Infusion(parsedInt));
                        }
                      });
                      newInfusionController.clear();
                    },
                  ),
                ),
                validator: (value) {
                  if (result.infusions.isEmpty) {
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
                widget.saveCallback(result);
                Navigator.of(context).pop();
              }
            });
          },
          child: const Text('Save'),
        ),
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
