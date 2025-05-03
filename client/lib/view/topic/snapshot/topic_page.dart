// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/view/topic/snapshot/topic_controller.dart';
import 'package:my_todo/view/topic/snapshot/topic_find_page.dart';
import 'package:my_todo/view/topic/snapshot/topic_me_page.dart';

class TopicSnapshotPage extends StatefulWidget {
  const TopicSnapshotPage({super.key});

  @override
  State<StatefulWidget> createState() => _SubscribeState();
}

class _SubscribeState extends State<TopicSnapshotPage>
    with AutomaticKeepAliveClientMixin {
  TopicSnapshotController controller = Get.find<TopicSnapshotController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Future.delayed(Duration.zero, () {
      controller.animationController.forward();
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
              ),
            ),
            isScrollable: true,
            tabs: [Tab(text: "topic_me".tr), Tab(text: "topic_find".tr)],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.addTopic(context, setState: setState);
            },
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          settingWidget(),
          const SizedBox(width: 10),
          multiWidget(context),
          const SizedBox(width: 10),
        ],
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [const TopicMePage(), const TopicFindPage()],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TopicFindItemModel {
  String icon;
  String name;
  String description;
  List<String> tags;
  int memberCount;

  TopicFindItemModel({
    required this.icon,
    required this.name,
    required this.description,
    required this.tags,
    required this.memberCount,
  });
}

class TopicFindItem extends StatelessWidget {
  const TopicFindItem({
    required this.model,
    this.showCaseDetail = false,
    this.showCaseKey,
    super.key,
  });
  final bool showCaseDetail;
  final GlobalKey<State<StatefulWidget>>? showCaseKey;
  final TopicFindItemModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 16, top: 8, bottom: 8),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: SvgPicture.asset(model.icon),
                ),
                const Padding(padding: EdgeInsets.only(left: 8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        model.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Row(children: [tags(context, model.tags)]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    model.memberCount.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(width: 3),
                  Icon(Icons.group, color: Colors.grey, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomDialog extends StatefulWidget {
  TopicFind model;

  CustomDialog({super.key, required this.model});

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // 定义飞入的动画效果，从屏幕外部飞入
    _animation = Tween<Offset>(
      begin: Offset(0, 1), // 开始位置在屏幕下方
      end: Offset(0, 0), // 结束位置在屏幕中心
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut, // 飞入时使用缓动效果
      ),
    );

    // 启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // 设置透明背景
      child: SlideTransition(
        position: _animation, // 将动画应用到弹窗
        child: Material(
          color:
              ThemeProvider.isDark
                  ? CupertinoColors.darkBackgroundGray
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.model.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.model.memberCount.toString(),
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(width: 3),
                        Icon(Icons.group, color: Colors.grey, size: 16),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(widget.model.description),
                SizedBox(height: 10),
                tags(context, widget.model.tags ?? []),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: Get.back,
                      child: Text("topic_apply_close".tr),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        topicApplyNewRequest(topicId: widget.model.id).then((v) {
                          Get.snackbar("topic_apply_join".tr, v);
                        });
                        Get.back();
                      },
                      child: Text("topic_apply_join".tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget tags(BuildContext context, List<String> values, {int limit = 26}) {
  List<Color> availableColors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.yellow[100]!,
    Colors.orange[100]!,
    Colors.pink[100]!,
    Colors.teal[100]!,
    Colors.cyan[100]!,
    Colors.lime[100]!,
    Colors.purple[100]!,
    Colors.indigo[100]!,
  ];

  // 限制字符串总长度
  int maxLength = limit;
  int currentLength = 0;
  List<String> displayedValues = [];

  for (var value in values) {
    if (currentLength + value.length > maxLength) {
      break; // 如果添加这个标签后长度超过30，则停止添加
    }
    displayedValues.add(value);
    currentLength += value.length;
  }

  // 生成标签
  List<Widget> tagWidgets =
      displayedValues.map((value) {
        // 从 availableColors 中随机选择一个颜色
        final color = availableColors[Random().nextInt(availableColors.length)];
        // 从 availableColors 中移除已选择的颜色，防止重复
        availableColors.remove(color);

        return Container(
          margin: EdgeInsets.only(right: 5), // 标签之间的间距
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 标签内边距
          decoration: BoxDecoration(
            color: color, // 设置背景颜色
            borderRadius: BorderRadius.circular(20), // 圆角
          ),
          child: Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      }).toList();

  // 返回 Row 组件显示标签
  return Row(children: tagWidgets);
}

Widget iconTag(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 标签的内边距
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColorLight, // 背景颜色
      borderRadius: BorderRadius.circular(20), // 圆角效果
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min, // 使Row尽量紧凑
      children: [
        Icon(
          Icons.location_on,
          size: 16, // 小一点的图标
          color: Theme.of(context).colorScheme.primary, // 图标颜色
        ),
        SizedBox(width: 4), // 图标和文本之间的间距
        Text(
          "unknown".tr, // 这里可以用国际化标签
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 10, // 小一点的字体
          ),
        ),
      ],
    ),
  );
}

Widget tag(
  BuildContext context, {
  required String value,
  required Color color,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      value,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 10,
      ),
    ),
  );
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key, required this.fieldValue});

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
