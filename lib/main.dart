// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:infusion_timer/additional_license_factory.dart';
import 'package:infusion_timer/widgets/collection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Test');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // register additional licenses
  LicenseRegistry.addLicense(AdditionalLicenseFactory.create);

  runApp(InfusionTimer());
}

class InfusionTimer extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<InfusionTimer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infusion Timer',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: CollectionPage(),
    );
  }
}
