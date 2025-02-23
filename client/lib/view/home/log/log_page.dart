// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/view/home/log/log_controller.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  LogController controller = Get.find<LogController>();

  @override
  Widget build(BuildContext context) {
    return todoScaffold(
      context,
      appBar: AppBar(actions: [
        IconButton(onPressed: () {
          controller.download(context);
        }, icon: const Icon(Icons.download)),
        const SizedBox(width: 10)
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: refreshContainer(
            onRefresh: controller.reload,
            child: SingleChildScrollView(
                child: Obx(() => Text(controller.content.value))),
            context: context),
      ),
    );
  }
}
