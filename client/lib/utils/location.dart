// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/permission.dart';
import 'package:permission_handler/permission_handler.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> getPosition(BuildContext context) async {
  bool serviceEnabled;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    showError('Location services are disabled.');
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }
  if (context.mounted) {
    bool ok =
        await grantPermission(context, Permission.location, allowWeb: true);
    if (!ok) {
      return Future.error('Location permissions are denied');
    }
  } else {
    showError("请手动打开定位权限");
    return Future.error('Location permissions are denied');
  }
  return await Geolocator.getCurrentPosition(forceAndroidLocationManager: true);
}
