// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:infusion_timer/backup_data.dart';
import 'package:infusion_timer/tea.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

const String _TEA_VESSEL_SIZE_SAVE_KEY = "tea_vessel_size";
const String _TEAS_SAVE_KEY = "teas";
const String _SESSION_SAVE_PREFIX = "session:";

class PersistenceService {
  static SharedPreferences _prefs;
  static int _teaVesselSizeMlPref = 100;
  static List<Tea> _teas = [];
  static Map<double, int> _savedSessions = {};

  static Future<void> init() async {
    // tried implementing this class as a singleton to init in the constructor but did not work because the constructor cannot be async
    _prefs = await SharedPreferences.getInstance();

    // read preferences
    var savedTeaVesselSizeMlPref = _prefs.getInt(_TEA_VESSEL_SIZE_SAVE_KEY);
    if (savedTeaVesselSizeMlPref != null) {
      _teaVesselSizeMlPref = savedTeaVesselSizeMlPref;
    }

    // read teas
    var savedTeasJson = _prefs.getStringList(_TEAS_SAVE_KEY);
    if (savedTeasJson == null) {
      // if there in no saved data, load the default included teas
      var defaultTeasJson =
          (await rootBundle.loadString('assets/default_data.json'));
      var teasJson = json.decode(defaultTeasJson) as List;
      _teas = teasJson.map((jsonTea) => Tea.fromJson(jsonTea)).toList();
    } else {
      // if there in no saved data, load the saved teas
      _teas = savedTeasJson
          .map((teaJson) => Tea.fromJson(jsonDecode(teaJson)))
          .toList();
    }

    // read sessions
    _teas.forEach((tea) {
      var teaSession = _prefs.getInt(_SESSION_SAVE_PREFIX + tea.id.toString());
      if (teaSession != null) {
        _savedSessions[tea.id] = teaSession;
      } else {
        _savedSessions.remove(tea.id);
      }
    });
  }

  static int get teaVesselSizeMlPref {
    return _teaVesselSizeMlPref;
  }

// cannot use regular setter because this must be async
  static Future<void> setTeaVesselSizeMlPref(int teaVesselSizeMl) async {
    _teaVesselSizeMlPref = teaVesselSizeMl;
    await _prefs.setInt(_TEA_VESSEL_SIZE_SAVE_KEY, teaVesselSizeMl);
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
        _TEAS_SAVE_KEY, _teas.map((tea) => jsonEncode(tea)).toList());
  }

  static Future<void> addTea(Tea tea) async {
    _teas.insert(0, tea);
    await _saveTeas();
  }

  static Future<void> deleteTea(Tea tea) async {
    // delete active session if any
    _teas.remove(tea);
    await _saveTeas();
    await _prefs.remove(_SESSION_SAVE_PREFIX + tea.id.toString());
  }

  static Future<void> updateTea(Tea tea) async {
    // tea was changed already and the change needs to be handled
    await _saveTeas();
    // make sure the saved infusion is not bigger than the number of infusions the tea has now
    var savedInfusion = _prefs.getInt(_SESSION_SAVE_PREFIX + tea.id.toString());
    if (savedInfusion != null && savedInfusion >= tea.infusions.length) {
      await _prefs.remove(_SESSION_SAVE_PREFIX + tea.id.toString());
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
      await _prefs.setInt(_SESSION_SAVE_PREFIX + key.toString(), value);
    });
  }

  static Map<double, int> get savedSessions {
    return _savedSessions;
  }

  static Future<int> getSession(Tea tea) async {
    return await _prefs.getInt(_SESSION_SAVE_PREFIX + tea.id.toString());
  }

  static Future<void> saveSession(Tea tea, int infusion) async {
    _savedSessions[tea.id] = infusion;
    await _prefs.setInt(_SESSION_SAVE_PREFIX + tea.id.toString(), infusion);
  }

  static Future<void> deleteSession(Tea tea) async {
    _savedSessions.remove(tea.id);
    await _prefs.remove(_SESSION_SAVE_PREFIX + tea.id.toString());
  }

  static BackupData getBackupData() {
    return BackupData(_teaVesselSizeMlPref, _teas, _savedSessions);
  }

  static Future<void> restoreFomBackup(BackupData backup) async {
    backup.validate();
    await setTeaVesselSizeMlPref(backup.teaVesselSizeMlPref);
    await setTeas(backup.teas);
    await setSavedSessions(backup.savedSessions);
  }
}
