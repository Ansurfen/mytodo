// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:my_todo/view/map/select/place.dart';

import 'package:my_todo/view/map/select/search_model.dart';
import 'package:my_todo/utils/location.dart';
import 'package:my_todo/utils/web_sandbox.dart';

class LocationController extends GetxController {
  late WebSandBoxController webSandBoxController;
  late final SearchModel model;
  List<Place> pos = [];
  Position? position;

  @override
  void onInit() {
    super.onInit();
    webSandBoxController = WebSandBoxController()
      ..id = "flutter-widget"
      ..width = '640'
      ..height = '360'
      ..style?.border = 'none'
      ..jsEnable = true
      ..loadFlutterAsset("assets/web/map/select.html")
      ..addEventChannel("add_marker", (event) {
        pos.add(Place(
            name: '',
            country: '',
            lat: double.parse(event.data["lat"]),
            lng: double.parse(event.data["lng"])));
      })
      ..addDartHandler("geolocation", (v) {
        if (position == null) {
          return "";
        }
        return jsonEncode(position);
      });
    model = SearchModel((v) {
      var coordinates = v as Map<String, double>;
      webSandBoxController.sendEvent("panTo",
          {"lat": "${coordinates["lat"]}", "lng": "${coordinates["lng"]}"});
    });
  }

  Future<bool> getLocation(BuildContext context) async {
    position = await getPosition(context);
    return true;
  }
}
