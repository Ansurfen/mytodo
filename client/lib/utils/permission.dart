// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {}

const List<String> _names = <String>[
  'calendar',
  'camera',
  'contacts',
  'location',
  'locationAlways',
  'locationWhenInUse',
  'mediaLibrary',
  'microphone',
  'phone',
  'photos',
  'photosAddOnly',
  'reminders',
  'sensors',
  'sms',
  'speech',
  'storage',
  'ignoreBatteryOptimizations',
  'notification',
  'access_media_location',
  'activity_recognition',
  'unknown',
  'bluetooth',
  'manageExternalStorage',
  'systemAlertWindow',
  'requestInstallPackages',
  'appTrackingTransparency',
  'criticalAlerts',
  'accessNotificationPolicy',
  'bluetoothScan',
  'bluetoothAdvertise',
  'bluetoothConnect',
  'nearbyWifiDevices',
  'videos',
  'audio',
  'scheduleExactAlarm',
  'sensorsAlways',
];

Future<bool> grantPermission(BuildContext context, dynamic perm,
    {bool allowWeb = false}) async {
  if (kIsWeb && allowWeb) {
    return true;
  }
  bool granted = true;
  List<String> perms = [];

  if (perm is Permission) {
    PermissionStatus status = await perm.request();
    if (status != PermissionStatus.granted) {
      granted = false;
      perms.add(_names[perm.value]);
    }
  } else if (perm is List<Permission>) {
    Map<Permission, PermissionStatus> status = await perm.request();
    for (var s in status.entries) {
      if (s.value != PermissionStatus.granted) {
        granted = false;
        perms.add(_names[s.key.value]);
      }
    }
  } else {
    EasyLoading.showError("permission_invalid".tr);
    return false;
  }
  if (!granted) {
    var lackPerms = perms.join(", ");
    if (context.mounted) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("You need to grant $lackPerms permissions."),
              content: Text('${"permission_please".tr} $lackPerms.'),
              actions: [
                CupertinoDialogAction(
                  child: Text(
                    'cancel'.tr,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    'confirm'.tr,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                ),
              ],
            );
          });
    } else {
      EasyLoading.showError("You need to grant $lackPerms permissions.");
    }
  }
  return true;
}

Future<bool> test(BuildContext context) async {
  PermissionStatus status = await Permission.camera.request();

  if (status != PermissionStatus.granted && context.mounted) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('You need to grant camera permissions'),
            content: const Text(
                'Please go to your mobile phone to set the permission to open the corresponding album'),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'confirm'.tr,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
            ],
          );
        });
  } else {
    return true;
  }
  return false;
}
