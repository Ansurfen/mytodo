// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/utils/web_sandbox.dart';
import 'package:my_todo/view/map/locate/locate_controller.dart';

class MapLocatePage extends StatefulWidget {
  final int taskId;
  final int condId;
  const MapLocatePage({super.key, required this.taskId, required this.condId});

  @override
  State<MapLocatePage> createState() => _MapLocatePageState();
}

class _MapLocatePageState extends State<MapLocatePage> {
  late LocateController locateController;

  @override
  void initState() {
    super.initState();
    locateController = LocateController(widget.taskId, widget.condId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locateController.getLocation(context),
      builder: (ctx, snap) {
        if (snap.hasData) {
          return webSandBox(locateController.webSandBoxController);
        }
        return Container(
          padding: const EdgeInsets.only(top: 80),
          child: Image.asset("assets/images/page_not_found.png"),
        );
      },
    );
  }
}
