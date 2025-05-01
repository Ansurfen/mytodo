import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/location.dart';
import 'package:my_todo/utils/web_sandbox.dart';

class LocateController {
  Position? position;

  late WebSandBoxController webSandBoxController;

  LocateController(int taskId, int condId) {
    webSandBoxController =
        WebSandBoxController()
          ..id = "flutter-widget"
          ..width = '640'
          ..height = '360'
          ..style?.border = 'none'
          ..jsEnable = true
          ..loadFlutterAsset("assets/web/map/locate.html")
          ..addEventChannel("screenshot", (evt) async {
            await taskCommitRequest(
              argument: {"locate": evt.data},
              taskId: taskId,
              condId: condId,
            );
          })
          ..addDartHandler("geolocation", (v) {
            if (position == null) {
              return "";
            }
            return jsonEncode(position);
          });
  }

  Future<bool> getLocation(BuildContext context) async {
    position = await getPosition(context);
    return true;
  }
}
