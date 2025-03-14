// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/model/dao/topic.dart';
import 'package:my_todo/view/add/add_controller.dart';
import 'package:my_todo/view/add/add_post_page.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:my_todo/view/add/text_option.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_topic_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin {
  AddController controller = Get.find<AddController>();

  Map<int, String> topics = {};
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () async {
      for (var element in (await TopicDao.findMany())) {
        topics[element.id!] = element.name;
      }
      setState(() {});
    });
  }

  Rx<double> distValue = 50.0.obs;

  @override
  Widget build(BuildContext context) {
    return todoCupertinoScaffold(
      context: context,
      appBar: todoCupertinoNavBar(
        context,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        middle: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onTertiary,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: UnderlineTabIndicator(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          tabs: [
            Tab(text: "task".tr),
            Tab(text: "topic".tr),
            Tab(text: "post".tr),
          ],
        ),
        trailing: IconButton(
          onPressed: controller.save,
          icon: Icon(
            FontAwesomeIcons.paperPlane,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          const AddTaskPage(),
          const AddTopicPage(),
          const AddPostPage(),
        ],
      ),
    );
  }
}
