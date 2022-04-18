// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:infusion_timer/tea.dart';
import 'package:infusion_timer/widgets/preferences_page.dart';
import 'package:infusion_timer/widgets/tea_card.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String ASSET_PREFIX = "assets/";
const String TEMP_FILE_PREFIX = "InfusionTimer_";
const String ANDROID_PROGRESS_NOTIFICATION_CHANNEL_ID = "brewingProgress";
const String ANDROID_PROGRESS_NOTIFICATION_CHANNEL_NAME = "Brewing Progress";
const String ANDROID_PROGRESS_NOTIFICATION_CHANNEL_DESCRIPTION =
    "Progress of the current infusion.";
const int PROGRESS_NOTIFICATION_ID = 42;
const String AUDIO_RESOURCE_NAME = "hand-bell-ringing-sound.wav";
const int ALARM_ID = 42;
const String SESSION_SAVE_PREFIX = "session:";

class TimerPage extends StatefulWidget {
  final Tea tea;

  TimerPage({Key key, this.tea}) : super(key: key);

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int currentInfusion = 1;
  AnimationController _animationController;
  Timer _notificationUpdateTimer;
  String sessionKey;
  static AudioCache _audioCache = AudioCache();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // for correcting the animation status when the app was in the background + notification progress
  DateTime infusionFinishTime;
  File audioFile;

  // need to return a future here to use .then()
  Future _loadSession() async {
    var prefs = await SharedPreferences.getInstance();
    var savedInfusion = await prefs.getInt(sessionKey);
    if (savedInfusion != null) {
      setState(() {
        currentInfusion = savedInfusion;
      });
    }
  }

  void _saveSession(int infusion) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(sessionKey, infusion);
  }

  void _deleteSession() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
  }

  static _ring() async {
    await _audioCache.play(AUDIO_RESOURCE_NAME);
  }

  _updateProgressNotification() async {
    int remainingDurationMs =
        infusionFinishTime.difference(DateTime.now()).inMilliseconds;
    bool finished = remainingDurationMs <= 0;
    if (finished) {
      // stop updating the notification when done so the user can dismiss it without it reappearing again instantly
      _stopDisplayingProgressNotification();
    }
    String remainingDurationText = finished
        ? "finished"
        : "${(remainingDurationMs / 1000).toStringAsFixed(0)}\u200As";
    // setting a short timeout to make the notification disappear if we dont need it anymore (paused, stopped brewing)
    // but when the brewing is finished, it should stay for a while so the user can still see it
    int timeout = finished ? Duration(minutes: 30).inMilliseconds : 1000;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(ANDROID_PROGRESS_NOTIFICATION_CHANNEL_ID,
            ANDROID_PROGRESS_NOTIFICATION_CHANNEL_NAME,
            channelDescription:
                ANDROID_PROGRESS_NOTIFICATION_CHANNEL_DESCRIPTION,
            importance: Importance.low,
            priority: Priority.defaultPriority,
            enableVibration: false,
            autoCancel: false,
            showProgress: true,
            progress:
                widget.tea.infusions[currentInfusion - 1].duration * 1000 -
                    remainingDurationMs,
            timeoutAfter: timeout,
            maxProgress:
                widget.tea.infusions[currentInfusion - 1].duration * 1000);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        PROGRESS_NOTIFICATION_ID,
        'Brewing ${widget.tea.name}, Infusion $currentInfusion',
        remainingDurationText,
        platformChannelSpecifics,
        payload: widget.tea.name);
  }

  _startDisplayingProgressNotification() {
    if (Platform.isAndroid) {
      if (_notificationUpdateTimer == null ||
          !_notificationUpdateTimer.isActive) {
        // if the timer is null or canceled, we need a new one
        _notificationUpdateTimer = Timer.periodic(Duration(milliseconds: 500),
            (Timer t) => _updateProgressNotification());
      }
    }
  }

  _stopDisplayingProgressNotification() {
    if (Platform.isAndroid) {
      if (_notificationUpdateTimer != null) {
        _notificationUpdateTimer.cancel();
      }
    }
  }

  _skipForwardIteration() {
    if (currentInfusion == widget.tea.infusions.length) {
      return;
    }
    setState(() {
      currentInfusion++;
      _saveSession(currentInfusion);
      _animationController.duration =
          Duration(seconds: widget.tea.infusions[currentInfusion - 1].duration);
      _animationController.reset();
    });
    if (Platform.isAndroid) {
      AndroidAlarmManager.cancel(ALARM_ID);
    }
    _stopDisplayingProgressNotification();
  }

  _skipBackwardIteration() {
    if (currentInfusion == 1) {
      return;
    }
    setState(() {
      currentInfusion--;
      if (currentInfusion == 1) {
        _deleteSession();
      } else {
        _saveSession(currentInfusion);
      }
      _animationController.duration =
          Duration(seconds: widget.tea.infusions[currentInfusion - 1].duration);
      _animationController.reset();
    });
    if (Platform.isAndroid) {
      AndroidAlarmManager.cancel(ALARM_ID);
    }
    _stopDisplayingProgressNotification();
  }

  _startPauseNext() {
    int remainingMs;
    setState(() {
      if (!_animationController.isAnimating) {
        if (_animationController.isCompleted) {
          if (currentInfusion == widget.tea.infusions.length) {
            // finished; back to tea collection
            Navigator.pop(context);
            return;
          } else {
            // starting next iteration
            _skipForwardIteration();
            // need to save one higher because the next infusion is already started
            _saveSession(currentInfusion + 1);
            _animationController.reset();
            remainingMs = _animationController.duration.inMilliseconds;
            // if the last infusion is started, delete the saved info
            if (currentInfusion == widget.tea.infusions.length) {
              _deleteSession();
            }
          }
        } else {
          if (_animationController.isDismissed) {
            // starting from the beginning
            if (currentInfusion == widget.tea.infusions.length) {
              _deleteSession();
            } else {
              _saveSession(currentInfusion + 1);
            }
          }
          // starting the beginning or resuming from pause
          remainingMs = ((1 - _animationController.value) *
                  _animationController.duration.inMilliseconds)
              .round();
        }
        // all cases
        _animationController.forward();
        _startDisplayingProgressNotification();
        infusionFinishTime =
            DateTime.now().add(Duration(milliseconds: remainingMs));
        if (Platform.isAndroid) {
          // not using wakeup true will cause long delays and potentially no sound at all
          AndroidAlarmManager.oneShotAt(infusionFinishTime, ALARM_ID, _ring,
              allowWhileIdle: true,
              exact: true,
              wakeup: true,
              alarmClock: true);
        }
      } else {
        // pausing
        _animationController.stop();
        _stopDisplayingProgressNotification();
        if (Platform.isAndroid) {
          AndroidAlarmManager.cancel(ALARM_ID);
        }
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    sessionKey = SESSION_SAVE_PREFIX + widget.tea.id.toString();

    _animationController = AnimationController(
      vsync: this,
    );

    // would be better to do before initializing the animation controller but cannot be awaited here
    _loadSession().then((value) => _animationController.duration =
        Duration(seconds: widget.tea.infusions[currentInfusion - 1].duration));

    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (Platform.isLinux) {
          _updateProgressNotification();
          // to ring: write the audio file to a temporary directory and then play is using aplay
          var tempDir = await getTemporaryDirectory();
          final soundBytes =
              await rootBundle.load(ASSET_PREFIX + AUDIO_RESOURCE_NAME);
          final buffer = soundBytes.buffer;
          final byteList = buffer.asUint8List(
              soundBytes.offsetInBytes, soundBytes.lengthInBytes);
          audioFile = new File(
              tempDir.path + "/" + TEMP_FILE_PREFIX + AUDIO_RESOURCE_NAME);
          if (!await audioFile.exists()) {
            await audioFile.writeAsBytes(byteList);
          }
          Process.run("aplay", [audioFile.path]);
        }
      }
    });
    _animationController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _animationController.value * 100;
    final progressIndicatorDiameter =
        (MediaQuery.of(context).size.height) * 0.4;
    return Scaffold(
      appBar: AppBar(
        title: Text("Tea Timer"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          // reverse to hide the tea card on top by default
          reverse: true,
          child: Column(
            children: [
              TeaCard(widget.tea, null, null,
                  PreferencesPage.teaVesselSizeMlPref, null),
              Container(
                margin: EdgeInsets.only(
                    left: progressIndicatorDiameter * 0.08,
                    right: progressIndicatorDiameter * 0.08,
                    top: progressIndicatorDiameter * 0.08,
                    bottom: progressIndicatorDiameter * 0.05),
                width: progressIndicatorDiameter,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LiquidCircularProgressIndicator(
                      value: _animationController.value,
                      borderColor: Theme.of(context).colorScheme.secondary,
                      borderWidth: 5.0,
                      direction: Axis.vertical,
                      center: FittedBox(
                        child: Stack(
                          alignment: _animationController.isAnimating
                              ? Alignment.center
                              : Alignment.bottomCenter,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: _animationController.isAnimating
                                      ? 0
                                      : progressIndicatorDiameter * 0.06),
                              child: Text(
                                "${(widget.tea.infusions[currentInfusion - 1].duration - widget.tea.infusions[currentInfusion - 1].duration * percentage / 100).toStringAsFixed(0)}\u200As",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: progressIndicatorDiameter * 0.2,
                                ),
                              ),
                            ),
                            Container(
                              height: progressIndicatorDiameter,
                              width: progressIndicatorDiameter,
                              child: IconButton(
                                // didnt find a proper way to remove the splash effect
                                splashRadius: 0.0001,
                                icon: Icon(() {
                                  if (_animationController.isCompleted) {
                                    if (currentInfusion ==
                                        widget.tea.infusions.length) {
                                      return Icons.arrow_back;
                                    } else {
                                      return Icons.skip_next;
                                    }
                                  } else if (_animationController.isAnimating) {
                                    return null;
                                  } else {
                                    return Icons.play_arrow;
                                  }
                                }()),
                                color: Colors.white.withOpacity(0.5),
                                onPressed: _startPauseNext,
                                iconSize: progressIndicatorDiameter * 0.65,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.skip_previous),
                      iconSize: progressIndicatorDiameter * 0.15,
                      onPressed:
                          currentInfusion == 1 ? null : _skipBackwardIteration),
                  Text(
                    "Infusion $currentInfusion/${widget.tea.infusions.length}",
                    style: TextStyle(fontSize: progressIndicatorDiameter * 0.1),
                  ),
                  IconButton(
                      icon: Icon(Icons.skip_next),
                      iconSize: progressIndicatorDiameter * 0.15,
                      onPressed: currentInfusion == widget.tea.infusions.length
                          ? null
                          : _skipForwardIteration)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // the timer animation will pause if the application is paused or whatever by android so the state must be corrected when resumed
    if (state == AppLifecycleState.resumed) {
      setState(() {
        Duration remainingDuration =
            infusionFinishTime.difference(DateTime.now());
        if (_animationController.isAnimating) {
          _animationController.value =
              (_animationController.duration - remainingDuration)
                      .inMilliseconds /
                  _animationController.duration.inMilliseconds;
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isAndroid) {
      AndroidAlarmManager.cancel(ALARM_ID);
    }
    // cancel any "finished" notification
    flutterLocalNotificationsPlugin.cancel(PROGRESS_NOTIFICATION_ID);
    _stopDisplayingProgressNotification();
    if (audioFile != null) {
      // no need to await
      audioFile.delete();
    }
    _animationController.dispose();
    super.dispose();
  }
}
