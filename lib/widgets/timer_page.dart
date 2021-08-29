import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:free_brew/tea.dart';
import 'package:free_brew/widgets/preferences_page.dart';
import 'package:free_brew/widgets/tea_card.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

final String assetPrefix = "assets/";
final String tempPrefix = "freeBrew_";
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
  bool paused = false;
  bool started = false;
  int displaySeconds;
  AnimationController _animationController;
  static AudioCache _audioCache = AudioCache();
  static AudioPlayer _audioPlayer;
  // for correcting the animation status when the app was in the background
  DateTime infusionFinishTime;
  File audioFile;

  static _ring() async {
    _audioPlayer = await _audioCache.play(audioResourceName);
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
        _animationController.forward();
        if (Platform.isAndroid) {
          infusionFinishTime =
              DateTime.now().add(Duration(milliseconds: remainingMs));
          AndroidAlarmManager.oneShotAt(
              DateTime.now().add(Duration(milliseconds: remainingMs)),
              alarmId,
              _ring,
              allowWhileIdle: true,
              exact: true,
              alarmClock: true);
        }
      } else {
        // pausing
        _animationController.stop();
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
                      borderColor: Theme.of(context).accentColor,
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
    if (audioFile != null) {
      // no need to await
      audioFile.delete();
    }
    _animationController.dispose();
    super.dispose();
  }
}
