// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:infusion_timer/additional_license_factory.dart';
import 'package:infusion_timer/widgets/collection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

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
