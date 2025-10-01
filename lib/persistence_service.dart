// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:infusion_timer/backup_data.dart';
import 'package:infusion_timer/tea.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _teaVesselSizeSaveKey = "tea_vessel_size";
const String _teasSaveKey = "teas";
const String _sessionSavePrefix = "session:";

class PersistenceService {
  static late SharedPreferences _prefs;
  static int _teaVesselSizeMlPref = 100;
  static List<Tea> _teas = [];
  static Map<double, int> _savedSessions = {};

  static Future<void> init() async {
    // tried implementing this class as a singleton to init in the constructor but did not work because the constructor cannot be async
    _prefs = await SharedPreferences.getInstance();

    // read preferences
    var savedTeaVesselSizeMlPref = _prefs.getInt(_teaVesselSizeSaveKey);
    if (savedTeaVesselSizeMlPref != null) {
      _teaVesselSizeMlPref = savedTeaVesselSizeMlPref;
    }

    // read teas
    var savedTeasJson = _prefs.getStringList(_teasSaveKey);
    if (savedTeasJson == null) {
      // if there in no saved data, load the default included teas
      var defaultTeasJson = (await rootBundle.loadString(
        'assets/default_data.json',
      ));
      var teasJson = json.decode(defaultTeasJson) as List;
      _teas = teasJson.map((jsonTea) => Tea.fromJson(jsonTea)).toList();
    } else {
      // if there in no saved data, load the saved teas
      _teas = savedTeasJson
          .map((teaJson) => Tea.fromJson(jsonDecode(teaJson)))
          .toList();
    }

    // read sessions
    for (var tea in _teas) {
      var teaSession = _prefs.getInt(_sessionSavePrefix + tea.id.toString());
      if (teaSession != null) {
        _savedSessions[tea.id] = teaSession;
      } else {
        _savedSessions.remove(tea.id);
      }
    }
  }

  static int get teaVesselSizeMlPref {
    return _teaVesselSizeMlPref;
  }

  // cannot use regular setter because this must be async
  static Future<void> setTeaVesselSizeMlPref(int teaVesselSizeMl) async {
    _teaVesselSizeMlPref = teaVesselSizeMl;
    await _prefs.setInt(_teaVesselSizeSaveKey, teaVesselSizeMl);
  }

  static List<Tea> get teas {
    return _teas;
  }

  // cannot use regular setter because this must be async
  static setTeas(List<Tea> teas) async {
    _teas = teas;
    await _saveTeas();
  }

  static Future<void> _saveTeas() async {
    await _prefs.setStringList(
      _teasSaveKey,
      _teas.map((tea) => jsonEncode(tea)).toList(),
    );
  }

  static Future<void> addTea(Tea tea) async {
    _teas.insert(0, tea);
    await _saveTeas();
  }

  static Future<void> deleteTea(Tea tea) async {
    _teas.remove(tea);
    await _saveTeas();
    // delete active session if any
    deleteSession(tea);
  }

  static Future<void> updateTea(Tea tea) async {
    // tea was changed already and the change needs to be handled
    await _saveTeas();
    // make sure the saved infusion is not bigger than the number of infusions the tea has now
    var savedInfusion = _prefs.getInt(_sessionSavePrefix + tea.id.toString());
    if (savedInfusion != null && savedInfusion >= tea.infusions.length) {
      deleteSession(tea);
    }
  }

  static Future bringTeaToFirstPosition(Tea tea) async {
    _teas.remove(tea);
    _teas.insert(0, tea);
    await _saveTeas();
  }

  // cannot use regular setter because this must be async
  static setSavedSessions(Map<double, int> savedSessions) async {
    _savedSessions = savedSessions;
    savedSessions.forEach((key, value) async {
      await _prefs.setInt(_sessionSavePrefix + key.toString(), value);
    });
  }

  static Map<double, int> get savedSessions {
    return _savedSessions;
  }

  static Future<int?> getSession(Tea tea) async {
    return _prefs.getInt(_sessionSavePrefix + tea.id.toString());
  }

  static Future<void> saveSession(Tea tea, int infusion) async {
    _savedSessions[tea.id] = infusion;
    await _prefs.setInt(_sessionSavePrefix + tea.id.toString(), infusion);
  }

  static Future<void> deleteSession(Tea tea) async {
    _savedSessions.remove(tea.id);
    await _prefs.remove(_sessionSavePrefix + tea.id.toString());
  }

  static BackupData getBackupData() {
    return BackupData(_teaVesselSizeMlPref, _teas, _savedSessions);
  }

  static Future<void> restoreFomBackup(BackupData backup) async {
    backup.validate();
    await _prefs.clear();
    await setTeaVesselSizeMlPref(backup.teaVesselSizeMlPref);
    await setTeas(backup.teas);
    await setSavedSessions(backup.savedSessions);
  }
}
