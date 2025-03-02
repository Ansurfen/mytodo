// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/view/topic/snapshot/topic_controller.dart';
import 'package:my_todo/view/topic/snapshot/topic_item.dart';

class TopicSnapshotPage extends StatefulWidget {
  const TopicSnapshotPage({super.key});

  @override
  State<StatefulWidget> createState() => _SubscribeState();
}

class _SubscribeState extends State<TopicSnapshotPage>
    with AutomaticKeepAliveClientMixin {
  TopicSnapshotController controller = Get.find<TopicSnapshotController>();

  Future<bool> getData() async {
    await controller.freshTopic();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Future.delayed(Duration.zero, () {
      controller.freshTopic();
    });
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeData.colorScheme.primary,
        title: Padding(
            padding: const EdgeInsets.only(left: 40),
            child: TabBar(
              controller: controller.tabController,
              labelColor: themeData.colorScheme.onPrimary,
              unselectedLabelColor: themeData.colorScheme.onTertiary,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: UnderlineTabIndicator(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    width: 1,
                    color: themeData.colorScheme.onPrimary,
                  )),
              isScrollable: true,
              tabs: [
                Tab(
                  text: "topic_me".tr,
                ),
                Tab(
                  text: "topic_find".tr,
                ),
              ],
            )),
        actions: [
          IconButton(
              onPressed: () {
                controller.addTopic(context, setState: setState);
              },
              icon: const Icon(Icons.add)),
          const SizedBox(
            width: 10,
          ),
          settingWidget(),
          const SizedBox(
            width: 10,
          ),
          multiWidget(context),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [_me(), _find()],
      ),
    );
  }

  Widget topicView(Size size) {
    return Obx(() => EmptyContainer(
          height: MediaQuery.sizeOf(context).height * 0.75,
          icon: Icons.rss_feed,
          desc: "no_topic".tr,
          what: "what_is_topic".tr,
          render: controller.topics.value.isNotEmpty,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: size.height * 0.35),
          onTap: () {
            showTipDialog(context, content: "what_is_topic".tr);
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: FadeAnimatedBuilder(
                  animation: controller.animationController,
                  opacity: TodoAnimateStyle.fadeOutOpacity(
                      controller.animationController),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.topics.value.length,
                    itemBuilder: (context, index) {
                      GetTopicDto chat = controller.topics.value[index];
                      final ValueKey<ExpansionTileCardState> k =
                          ValueKey(ExpansionTileCardState());
                      return TopicCard(
                        model: chat,
                        title: chat.name,
                        msg: chat.desc,
                        key: k,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 10);
                    },
                  ))),
        ));
  }

  Widget _me() {
    return refreshContainer(
        context: context,
        onRefresh: () {
          controller.freshTopic();
        },
        onLoad: () {},
        child: SingleChildScrollView(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SearchTextField(fieldValue: (v) {})),
          topicView(MediaQuery.sizeOf(context)),
          const SizedBox(height: 50)
        ])));
  }

  Widget _find() {
    return refreshContainer(
        context: context,
        onRefresh: () {
          controller.freshTopic();
        },
        onLoad: () {},
        child: SingleChildScrollView(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SearchTextField(fieldValue: (v) {})),
          topicView(MediaQuery.sizeOf(context)),
          const SizedBox(height: 50)
        ])));
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.fieldValue,
  });

  final ValueChanged<String> fieldValue;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      onChanged: (String value) {
        fieldValue('The text has changed to: $value');
      },
      onSubmitted: (String value) {
        fieldValue('Submitted text: $value');
      },
    );
  }
}
