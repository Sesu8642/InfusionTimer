// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:infusion_timer/tea.dart';

const int _dataSchemaVersion = 1;

class BackupData {
  final int? _teaVesselSizeMlPref;
  final List<Tea>? _teas;
  final Map<double, int>? _savedSessions;

  BackupData(this._teaVesselSizeMlPref, this._teas, this._savedSessions);

  BackupData.fromJson(Map<String, dynamic> json)
      : _teaVesselSizeMlPref = json['teaVesselSizeMlPref'],
        _teas = List<Tea>.from(json['teas'].map((i) => Tea.fromJson(i))),
        _savedSessions = Map<double, int>.from(json['savedSessions']
            .map((key, val) => MapEntry<double, int>(double.parse(key), val)));

  Map toJson() => {
        'version': _dataSchemaVersion,
        'teaVesselSizeMlPref': _teaVesselSizeMlPref,
        'teas': _teas,
        'savedSessions':
            _savedSessions!.map((key, value) => MapEntry(key.toString(), value))
      };

  validate() {
    if (_teaVesselSizeMlPref == null) {
      throw const FormatException("teaVesselSizeMlPref is required.");
    }
    if (_teas == null) {
      throw const FormatException("teas is required.");
    }
    if (_savedSessions == null) {
      throw const FormatException("savedSessions is required.");
    }
    for (var tea in _teas) {
      tea.validate();
    }
    if (_teas.map((tea) => tea.id).toSet().length < _teas.length) {
      throw const FormatException("Tea IDs are not unique.");
    }
    _savedSessions.forEach((key, value) {
      if (value <= 1) {
        throw const FormatException(
            "savedSessions contains a too small infusion index.");
      }
      try {
        Tea matchingTea = _teas.firstWhere((tea) => tea.id == key);
        if (value > matchingTea.infusions.length) {
          throw const FormatException(
              "savedSessions contains a session that is too large.");
        }
      } on StateError {
        throw const FormatException(
            "savedSessions contains a session for a nonexistent tea.");
      }
    });
  }

  int get teaVesselSizeMlPref {
    return _teaVesselSizeMlPref!;
  }

  List<Tea> get teas {
    return _teas!;
  }

  Map<double, int> get savedSessions {
    return _savedSessions!;
  }
}
