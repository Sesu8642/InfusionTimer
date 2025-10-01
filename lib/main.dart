// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:infusion_timer/additional_license_factory.dart';
import 'package:infusion_timer/persistence_service.dart';
import 'package:infusion_timer/widgets/collection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  const String notificationIconName = 'notification_icon';

// initialize FlutterLocalNotificationsPlugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(notificationIconName);
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'OK');
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // register additional licenses
  LicenseRegistry.addLicense(AdditionalLicenseFactory.create);

  // init persistence service
  await PersistenceService.init();

  runApp(const InfusionTimer());
}

class InfusionTimer extends StatefulWidget {
  const InfusionTimer({super.key});

  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<InfusionTimer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enthusiast Tea Timer',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
            primary: Colors.teal,
            secondary: Colors.teal,
            tertiary: Colors.teal),
        useMaterial3: true,
      ),
      home: const CollectionPage(),
    );
  }
}
