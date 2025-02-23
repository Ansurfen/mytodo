// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/utils/web_sandbox.dart';

class MapLocatePage extends StatefulWidget {
  const MapLocatePage({super.key});

  @override
  State<MapLocatePage> createState() => _MapLocatePageState();
}

class _MapLocatePageState extends State<MapLocatePage> {
  WebSandBoxController webSandBoxController = WebSandBoxController()
    ..id = "flutter-widget"
    ..width = '640'
    ..height = '360'
    ..style?.border = 'none'
    ..jsEnable = true
    ..loadFlutterAsset("assets/web/map/locate.html")
    ..addEventChannel("screenshot", (evt) {
      Get.back(result: evt.data);
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: webSandBox(webSandBoxController));
  }
}
