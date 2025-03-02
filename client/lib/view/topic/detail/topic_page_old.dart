// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/input.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/component/timeline/flutter_timeline.dart';
import 'package:my_todo/component/timeline/indicator_position.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/chat/conversation/chat_bubble.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/view/topic/detail/topic_controller_old.dart';

class TopicPage extends StatefulWidget {
  const TopicPage({super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  TopicController controller = Get.find<TopicController>();
  TodoInputController todoInputController = TodoInputController(
    TextEditingController(),
    TextEditingController(),
  );
  List conversation = [];
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<EmojiPickerState>();
    todoInputController.config = Config(
      emojiViewConfig: EmojiViewConfig(
        buttonMode: ButtonMode.MATERIAL,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      categoryViewConfig: CategoryViewConfig(
        indicatorColor: Theme.of(context).primaryColor,
        iconColorSelected: Theme.of(context).primaryColor,
        backspaceColor: Theme.of(context).primaryColor,
      ),
    );
    TimePointPainter.init(context);
    controller.event.add(
      TimelineEventDisplay(
        anchor: IndicatorPosition.top,
        indicatorOffset: const Offset(0, 8),
        child: TimelineEventCard(
          title: Container(),
          content: Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Obx(
              () => Text(
                '${DateFormat("dd, MMM").format(controller.startDate.value)} - ${DateFormat("dd, MMM").format(controller.endDate.value)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w100,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        indicatorSize: 32,
        indicator: InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            // setState(() {
            //   isDatePopupOpen = true;
            // });
            controller.showDemoDialog(context: context);
          },
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(64)),
            ),
            child: const Icon(Icons.calendar_month, color: Colors.white),
          ),
        ),
      ),
    );
    controller.event.addAll([
      yearEvent,
      dayEvent,
      yearEvent,
      smallEventDisplay,
      smallEventDisplay,
      smallEventDisplay,
      TimelineEventDisplay(
        child: Card(
          child: TimelineEventCard(
            title: Text("click the + button"),
            content: Text("to add a new event item"),
          ),
        ),
      ),
    ]);
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: todoAppBar(
        context,
        title: Text(controller.model.name),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              RouterProvider.viewTopicMember(controller.model.id);
            },
            icon: const Icon(Icons.group),
          ),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () async {
              TodoShare.shareUri(
                context,
                Uri.parse(controller.model.inviteCode),
              );
            },
            icon: const Icon(Icons.share),
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          todoTabBar(
            context,
            tabs: [Tab(text: "timeline".tr), Tab(text: "discuss".tr)],
            controller: controller.tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildTimeline(context),
                Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  body: refreshContainer(
                    context: context,
                    onLoad: () {},
                    onRefresh: () {},
                    child: EmptyContainer(
                      icon: Icons.chat,
                      desc: 'try to send the first message',
                      what: '',
                      render: conversation.isNotEmpty,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        reverse: true,
                        itemCount: conversation.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map msg = conversation[index];
                          return ChatBubble(
                            message: msg["message"],
                            username: msg["username"],
                            time: msg["time"],
                            type: msg['type'],
                            replyText: msg["replyText"],
                            isMe: msg['isMe'],
                            isGroup: msg['isGroup'],
                            isReply: msg['isReply'],
                            replyName: "",
                          );
                        },
                      ),
                    ),
                  ),
                  bottomNavigationBar: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? HexColor.fromInt(0xceced2)
                                          : Colors.grey.withOpacity(0.8),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: TodoInput(
                                showChild: false,
                                controller: todoInputController,
                                onTap: (String value) {
                                  conversation.insert(0, {
                                    "username": "",
                                    "time": "15 min ago",
                                    "replyText": "",
                                    "isMe": true,
                                    "message": value,
                                    "isGroup": false,
                                    "isReply": false,
                                    "replyName": "",
                                    "type": "text",
                                  });
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          TodoInputView(
                            controller: todoInputController,
                            state: key,
                            maxWidth: constraints.maxWidth,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return refreshContainer(
      context: context,
      onRefresh: () {},
      onLoad: () {},
      child: TimelineTheme(
        data: TimelineThemeData(
          strokeWidth: 3,
          lineColor: HexColor.fromInt(0xceced2),
          itemGap: 100,
          lineGap: 0,
        ),
        child: Timeline(
          anchor: IndicatorPosition.center,
          indicatorSize: 56,
          altOffset: const Offset(10, 5),
          events: controller.event,
        ),
      ),
    );
  }

  TimelineEventDisplay get yearEvent {
    return TimelineEventDisplay(
      anchor: IndicatorPosition.top,
      child: Text(
        "Today",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      indicatorSize: 15,
      indicator: timePoint(
        15,
        Colors.white,
        borderColor: Theme.of(context).primaryColor,
        borderWidth: 2,
      ),
    );
  }

  Widget get randomTimePoint {
    var style = TimePointPainter.random();
    return timePoint(
      style.size,
      style.fillColor,
      borderColor: style.borderColor,
      borderWidth: style.borderWidth,
    );
  }

  TimelineEventDisplay get dayEvent {
    return TimelineEventDisplay(
      anchor: IndicatorPosition.top,
      indicatorSize: 12,
      indicator: timePoint(12, Theme.of(context).primaryColor),
      child: const Text(
        "Order #1069\n20,000 Genoplan DNA kits shipped.\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  TimelineEventDisplay get smallEventDisplay {
    return TimelineEventDisplay(
      child: Card(
        child: TimelineEventCard(
          title: Text("click the + button"),
          content: Text("to add a new event item"),
        ),
      ),
      anchor: IndicatorPosition.top,
      indicatorSize: 12,
      indicator: randomTimePoint,
    );
  }

  Widget timePoint(
    double size,
    Color fillColor, {
    Color? borderColor,
    double? borderWidth,
  }) {
    Border? border;
    if (borderColor != null) {
      border = Border.all(color: borderColor, width: borderWidth ?? 1);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        border: border,
      ),
    );
  }
}

class TimePointStyle {
  final double size;
  Color fillColor;
  Color? borderColor;
  double? borderWidth;

  TimePointStyle(
    this.size,
    this.fillColor, {
    this.borderColor,
    this.borderWidth,
  });
}

class TimePointPainter {
  static late List<TimePointStyle> _style;
  static Random r = Random();

  static init(BuildContext context) {
    _style = [
      TimePointStyle(
        12,
        Colors.white,
        borderColor: Theme.of(context).primaryColor,
      ),
      TimePointStyle(12, Colors.white, borderColor: Colors.grey),
      TimePointStyle(12, Theme.of(context).primaryColor),
      TimePointStyle(12, Colors.grey),
      TimePointStyle(
        15,
        Colors.white,
        borderColor: Theme.of(context).primaryColor,
        borderWidth: 2,
      ),
    ];
  }

  static TimePointStyle random() {
    return _style[r.nextInt(_style.length)];
  }
}
