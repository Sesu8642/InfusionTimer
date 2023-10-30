// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:infusion_timer/persistence_service.dart';
import 'package:infusion_timer/tea.dart';
import 'package:infusion_timer/widgets/preferences_page.dart';
import 'package:infusion_timer/widgets/tea_actions_bottom_sheet.dart';
import 'package:infusion_timer/widgets/tea_card.dart';
import 'package:infusion_timer/widgets/tea_input_dialog.dart';
import 'package:infusion_timer/widgets/timer_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({Key? key}) : super(key: key);

  @override
  CollectionPageState createState() => CollectionPageState();
}

class CollectionPageState extends State<CollectionPage> {
  final searchController = TextEditingController();
  String _versionName = "";
  bool searchBarShown = false;

  List<Tea> _getFilteredTeas(String filterText) {
    return PersistenceService.teas
        .where((tea) => tea.name!.toLowerCase().contains(filterText))
        .followedBy(PersistenceService.teas.where((tea) =>
            !tea.name!.toLowerCase().contains(filterText) &&
            tea.notes!.toLowerCase().contains(filterText)))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) => _versionName = value.version);

    // ask for permissions
    const flutterBackgroundAndroidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Enthusiast Tea Timer",
      notificationText: "Enthusiast Tea Timer is running in the background.",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon:
          AndroidResource(name: 'notification_icon', defType: 'drawable'),
      enableWifiLock: false,
      showBadge: false,
    );

    if (Platform.isAndroid) {
      FlutterBackground.hasPermissions.then((hasPermissions) {
        if (!hasPermissions) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Permission needed'),
              content: const Text(
                  'Please grant this app the following permissions if propted:\n\n1) Display notifications: for accurate timing and visible brewing progress while in the background\n\n2) Run in the background: for accurate timing. It will only do so while a timer is running.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'OK');
                    // permission to run in background
                    FlutterBackground.initialize(
                        androidConfig: flutterBackgroundAndroidConfig);
                    // init a second time because of this bug: https://github.com/JulianAssmann/flutter_background/issues/76
                    FlutterBackground.initialize(
                        androidConfig: flutterBackgroundAndroidConfig);

                    // permission to display notifications
                    FlutterLocalNotificationsPlugin
                        flutterLocalNotificationsPlugin =
                        FlutterLocalNotificationsPlugin();
                    flutterLocalNotificationsPlugin
                        .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin>()!
                        .requestNotificationsPermission();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Tea Collection")),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary),
                child: const Text(
                  "Enthusiast Tea Timer",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Preferences"),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const PreferencesPage(key: null)));
                  // when returning from preferences, update vessel size
                  setState(() {});
                },
              ),
              AboutListTile(
                icon: const Icon(Icons.favorite),
                applicationIcon: SizedBox(
                  height: IconTheme.of(context).resolve(context).size,
                  width: IconTheme.of(context).resolve(context).size,
                  child: Image.asset(
                    "assets/icon_simple.png",
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                applicationVersion: _versionName,
                applicationLegalese:
                    "Copyright (c) 2021 Sesu8642\n\nhttps://github.com/Sesu8642/InfusionTimer",
                aboutBoxChildren: const [
                  Text(
                    "\nMany thanks to Mei Leaf (meileaf.com) for their permission to include data from their brewing guide!",
                    style: TextStyle(fontSize: 14),
                  )
                ],
              )
            ],
          ),
        ),
        body: Column(
          children: [
            searchBarShown
                ? Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for a tea',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchBarShown = false;
                                    searchController.text = "";
                                  });
                                },
                                icon: const Icon(Icons.close)),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
            Flexible(
              child: ListView.builder(
                itemCount: _getFilteredTeas(searchController.text).length,
                itemBuilder: (context, i) {
                  return TeaCard(_getFilteredTeas(searchController.text)[i],
                      (tea) async {
                    var future = Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimerPage(tea: tea)),
                    );
                    PersistenceService.bringTeaToFirstPosition(tea);
                    await future;
                    setState(() {
                      // update session info
                    });
                  },
                      (tea) => {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) =>
                                    TeaActionsBottomSheet(
                                        tea,
                                        (tea) => {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) =>
                                                        TeaInputDialog(
                                                  tea,
                                                  (tea) {
                                                    PersistenceService
                                                            .updateTea(tea)
                                                        .then((value) {
                                                      setState(() {});
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                  },
                                                  (tea) {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              )
                                            }, (tea) async {
                                      await PersistenceService.deleteTea(tea);
                                      setState(() {});
                                    }))
                          },
                      PersistenceService.teaVesselSizeMlPref,
                      PersistenceService.savedSessions[
                          _getFilteredTeas(searchController.text)[i].id]);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            searchBarShown
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: FloatingActionButton(
                      heroTag: "FloatingActionButtonSearchCollection",
                      onPressed: () {
                        setState(() {
                          searchBarShown = true;
                        });
                      },
                      tooltip: 'Search Collection',
                      child: const Icon(Icons.search),
                    ),
                  ),
            FloatingActionButton(
              heroTag: "FloatingActionButtonAddTea",
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => TeaInputDialog(
                    Tea.withGeneratedId(null, null, null, [], null, 0),
                    (tea) {
                      setState(
                        () {
                          PersistenceService.addTea(tea);
                        },
                      );
                      Navigator.of(context).pop();
                    },
                    (tea) {
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
              tooltip: 'Add Tea',
              child: const Icon(Icons.add),
            ),
          ],
        ));
  }
}
