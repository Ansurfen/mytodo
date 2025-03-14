// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:math';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/main5.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/view/add/add_task_page.dart';
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
        children: [_me(), _find()],
      ),
    );
  }

  Widget topicView(Size size) {
    return Obx(
      () => EmptyContainer(
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
              controller.animationController,
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.topics.value.length,
              itemBuilder: (context, index) {
                GetTopicDto chat = controller.topics.value[index];
                final ValueKey<ExpansionTileCardState> k = ValueKey(
                  ExpansionTileCardState(),
                );
                return TopicCard(
                  model: chat,
                  title: chat.name,
                  msg: chat.desc,
                  key: k,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 0.5,
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Divider(
                      color: ThemeProvider.contrastColor(
                        context,
                        light: Colors.grey,
                        dark: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget findView(Size size) {
    return Obx(
      () => EmptyContainer(
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
              controller.animationController,
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.topics.value.length,
              itemBuilder: (context, index) {
                GetTopicDto chat = controller.topics.value[index];
                return InkWell(
                  onTap: () {
                    _showCustomDialog(context);
                  },
                  child: TopicFindItem(
                    model: Mail(
                      sender: Mock.username(),
                      sub: Mock.text(),
                      msg: Mock.text(),
                      date: Mock.dateTime().toString(),
                      isUnread: false,
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 0.5,
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Divider(
                      color: ThemeProvider.contrastColor(
                        context,
                        light: Colors.grey,
                        dark: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _me() {
    return refreshContainer(
      context: context,
      onRefresh: () {
        controller.freshTopic();
      },
      onLoad: () {},
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SearchTextField(fieldValue: (v) {}),
            ),
            topicView(MediaQuery.sizeOf(context)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _find() {
    return refreshContainer(
      context: context,
      onRefresh: () {
        controller.freshTopic();
      },
      onLoad: () {},
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SearchTextField(fieldValue: (v) {}),
            ),
            findView(MediaQuery.sizeOf(context)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击外部不能关闭弹窗
      builder: (BuildContext context) {
        return CustomDialog();
      },
    );
  }
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
  final Mail model;

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
                  child: SvgPicture.asset(
                    animalMammal[Mock.number(max: animalMammal.length - 1)],
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.sender,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        model.sub,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          tags(
                            context,
                            List.generate(Mock.number(max: 5), (idx) {
                              return Mock.username();
                            }),
                          ),
                        ],
                      ),
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
                    Mock.number().toString(),
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

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击外部不能关闭弹窗
      builder: (BuildContext context) {
        return CustomDialog();
      },
    );
  }
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({super.key});

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  Mock.username(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                IconButton(
                  onPressed: () {
                    
                  },
                  icon: Icon(Icons.abc),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 点击按钮关闭弹窗
                  },
                  child: Text("关闭弹窗"),
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
