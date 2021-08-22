import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:free_brew/widgets/collection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }
  runApp(FreeBrew());
}

class FreeBrew extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<FreeBrew> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeBrew',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CollectionPage(),
    );
  }
}
