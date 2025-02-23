// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/model/dto/task.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';

class TaskCardModel {
  int? id;
  String name;
  String topic;
  String desc;
  DateTime startAt;
  List<int> cond;

  TaskCardModel(this.name, this.topic, this.desc, this.startAt, this.cond,
      {this.id});
}

class TaskCard extends StatelessWidget {
  final GetTaskDto model;

  const TaskCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    for (var i = 0; i < model.conds.length; i++) {
      if (model.conds[i] == TaskCondType.qr.index) {
        icons.add(Icon(Icons.crop_free,
            color: Theme.of(context).colorScheme.onPrimary));
      } else if (model.conds[i] == TaskCondType.hand.index) {
        icons.add(Icon(Icons.handshake,
            color: Theme.of(context).colorScheme.onPrimary));
      } else if (model.conds[i] == TaskCondType.locale.index) {
        icons.add(Icon(Icons.location_on,
            color: Theme.of(context).colorScheme.onPrimary));
      }
      if (i + 1 != model.conds.length) {
        icons.add(const SizedBox(width: 5));
      }
    }
    return GestureDetector(
        onTap: () {
          RouterProvider.viewTaskDetail(model.id);
        },
        child: Card(
          color: ThemeProvider.contrastColor(context,
              light: HexColor.fromInt(0xfafafa),
              dark: HexColor.fromInt(0x1c1c1e)),
          shadowColor: Colors.black,
          elevation: 2,
          borderOnForeground: false,
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          model.topic,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(DateFormat("yyyy/MM/dd HH:mm:ss")
                        .format(model.departure)),
                  ],
                ),
                Row(
                  children: [...icons],
                )
              ],
            ),
          ),
        ));
  }
}
