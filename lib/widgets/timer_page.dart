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

final String assetPrefix = "assets/";
final String tempPrefix = "InfusionTimer_";
final String androidProgressNotificationChannelId = "brewingProgress";
final String androidProgressNotificationChannelName = "Brewing Progress";
final String androidProgressNotificationChannelDescription =
    "Progress of the current infusion.";
final int progressNotificationId = 42;
final String audioResourceName = "hand-bell-ringing-sound.wav";
final int alarmId = 42;

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
  static AudioCache _audioCache = AudioCache();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // for correcting the animation status when the app was in the background + notification progress
  DateTime infusionFinishTime;
  File audioFile;

  static _ring() async {
    await _audioCache.play(audioResourceName);
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
        AndroidNotificationDetails(androidProgressNotificationChannelId,
            androidProgressNotificationChannelName,
            channelDescription: androidProgressNotificationChannelDescription,
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
        progressNotificationId,
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
      _animationController.duration =
          Duration(seconds: widget.tea.infusions[currentInfusion - 1].duration);
      _animationController.reset();
    });
    if (Platform.isAndroid) {
      AndroidAlarmManager.cancel(alarmId);
    }
    _stopDisplayingProgressNotification();
  }

  _skipBackwardIteration() {
    if (currentInfusion == 1) {
      return;
    }
    setState(() {
      currentInfusion--;
      _animationController.duration =
          Duration(seconds: widget.tea.infusions[currentInfusion - 1].duration);
      _animationController.reset();
    });
    if (Platform.isAndroid) {
      AndroidAlarmManager.cancel(alarmId);
    }
    _stopDisplayingProgressNotification();
  }

  _startPause() {
    int remainingMs;
    setState(() {
      if (!_animationController.isAnimating) {
        if (_animationController.isCompleted) {
          // restarting
          _animationController.reset();
          remainingMs = _animationController.duration.inMilliseconds;
        } else {
          // resuming from pause
          remainingMs = ((1 - _animationController.value) *
                  _animationController.duration.inMilliseconds)
              .round();
        }
        // all cases including starting the first time
        _animationController.forward();
        _startDisplayingProgressNotification();
        infusionFinishTime =
            DateTime.now().add(Duration(milliseconds: remainingMs));
        if (Platform.isAndroid) {
          // not using wakeup true will cause long delays and potentially no sound at all
          AndroidAlarmManager.oneShotAt(infusionFinishTime, alarmId, _ring,
              allowWhileIdle: true, exact: true, wakeup: true);
        }
      } else {
        // pausing
        _animationController.stop();
        _stopDisplayingProgressNotification();
        if (Platform.isAndroid) {
          AndroidAlarmManager.cancel(alarmId);
        }
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.tea.infusions[0].duration),
    );

    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (Platform.isLinux) {
          _updateProgressNotification();
          // progress to next iteration
          _skipForwardIteration();
          // to ring: write the audio file to a temporary directory and then play is using aplay
          var tempDir = await getTemporaryDirectory();
          final soundBytes =
              await rootBundle.load(assetPrefix + audioResourceName);
          final buffer = soundBytes.buffer;
          final byteList = buffer.asUint8List(
              soundBytes.offsetInBytes, soundBytes.lengthInBytes);
          audioFile =
              new File(tempDir.path + "/" + tempPrefix + audioResourceName);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Tea Timer"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TeaCard(
                  widget.tea, null, null, PreferencesPage.teaVesselSizeMlPref),
              Container(
                margin: EdgeInsets.all(30),
                width: (MediaQuery.of(context).size.height - 100) * 0.5,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LiquidCircularProgressIndicator(
                      value: _animationController.value,
                      borderColor: Theme.of(context).colorScheme.secondary,
                      borderWidth: 5.0,
                      direction: Axis.vertical,
                      center: Text(
                        "${(widget.tea.infusions[currentInfusion - 1].duration - widget.tea.infusions[currentInfusion - 1].duration * percentage / 100).toStringAsFixed(0)}\u200As",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 50),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                "Infusion $currentInfusion/${widget.tea.infusions.length}",
                style: TextStyle(fontSize: 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed:
                          currentInfusion == 1 ? null : _skipBackwardIteration),
                  const SizedBox(width: 10),
                  IconButton(
                      icon: Icon(_animationController.isCompleted ||
                              !_animationController.isAnimating
                          ? Icons.play_arrow
                          : Icons.pause),
                      onPressed: _startPause),
                  const SizedBox(width: 10),
                  IconButton(
                      icon: Icon(Icons.skip_next),
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
      AndroidAlarmManager.cancel(alarmId);
    }
    // cancel any "finished" notification
    flutterLocalNotificationsPlugin.cancel(progressNotificationId);
    _stopDisplayingProgressNotification();
    if (audioFile != null) {
      // no need to await
      audioFile.delete();
    }
    _animationController.dispose();
    super.dispose();
  }
}
