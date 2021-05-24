import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:free_brew/tea.dart';

class TeaCard extends StatelessWidget {
  final Tea tea;
  final Function(Tea) tapCallback;
  final Function(Tea) longPressCallback;

  TeaCard(this.tea, this.tapCallback, this.longPressCallback);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: GestureDetector(
          child: InkWell(
            onTap: tapCallback == null ? null : () => tapCallback(tea),
            onLongPress:
                longPressCallback == null ? null : () => longPressCallback(tea),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Center(child: Text(tea.name)),
                  subtitle: Center(child: Text(tea.notes)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.thermostat_outlined),
                    Text(tea.temperature.toString() + " °C"),
                    const SizedBox(width: 8),
                    Icon(Icons.grass),
                    Text(tea.gPer100Ml.toString() + " g/100ml"),
                    const SizedBox(width: 8),
                    Icon(Icons.repeat),
                    Text(tea.infusions.length.toString() + " infusions"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
