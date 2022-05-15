// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:infusion_timer/tea.dart';

const int _DATA_SCHEMA_VERSION = 1;

class BackupData {
  final int _teaVesselSizeMlPref;
  final List<Tea> _teas;
  final Map<double, int> _savedSessions;

  BackupData(this._teaVesselSizeMlPref, this._teas, this._savedSessions);

  BackupData.fromJson(Map<String, dynamic> json)
      : this._teaVesselSizeMlPref = json['teaVesselSizeMlPref'],
        this._teas = List<Tea>.from(json['teas'].map((i) => Tea.fromJson(i))),
        this._savedSessions = Map<double, int>.from(json['savedSessions']
            .map((key, val) => MapEntry<double, int>(double.parse(key), val)));

  Map toJson() => {
        'version': _DATA_SCHEMA_VERSION,
        'teaVesselSizeMlPref': _teaVesselSizeMlPref,
        'teas': _teas,
        'savedSessions': _savedSessions
            .map((key, value) => new MapEntry(key.toString(), value))
      };

  validate() {
    if (_teaVesselSizeMlPref == null) {
      throw FormatException("teaVesselSizeMlPref is required.");
    }
    if (_teas == null) {
      throw FormatException("teas is required.");
    }
    if (_savedSessions == null) {
      throw FormatException("savedSessions is required.");
    }
    _teas.forEach((tea) {
      tea.validate();
    });
    if (_teas.map((tea) => tea.id).toSet().length < _teas.length) {
      throw FormatException("Tea IDs are not unique.");
    }
    _savedSessions.forEach((key, value) {
      if (key == null || value == null) {
        throw FormatException("savedSessions contains a null value.");
      }
    });
  }

  int get teaVesselSizeMlPref {
    return _teaVesselSizeMlPref;
  }

  List<Tea> get teas {
    return _teas;
  }

  Map<double, int> get savedSessions {
    return _savedSessions;
  }
}
