// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:infusion_timer/tea.dart';

class TeaCard extends StatelessWidget {
  final Tea tea;
  final Function(Tea) tapCallback;
  final Function(Tea) longPressCallback;
  final int teaVesselSize;
  final int infusionOfActiveSession;

  TeaCard(this.tea, this.tapCallback, this.longPressCallback,
      this.teaVesselSize, this.infusionOfActiveSession);

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
                  subtitle:
                      tea.notes.isEmpty ? null : Center(child: Text(tea.notes)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.thermostat_outlined),
                    Text(tea.temperature.toString() + " °C"),
                    const SizedBox(width: 8),
                    Icon(Icons.grass),
                    Text(teaVesselSize != null
                        ? "${((tea.gPer100Ml * teaVesselSize).round() / 100).toString()} g/ ${teaVesselSize.toString()}ml"
                        : "null"),
                    const SizedBox(width: 8),
                    Icon(Icons.repeat),
                    Text(tea.infusions.length.toString() + " infusions"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: infusionOfActiveSession == null
                      ? []
                      : [
                          Text(
                              "Current brew: ${tea.infusions.length - infusionOfActiveSession + 1} more infusion(s) to go.")
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
