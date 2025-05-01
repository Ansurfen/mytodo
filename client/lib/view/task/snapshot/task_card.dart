// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/topic.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/clipboard.dart';
import 'package:my_todo/utils/json.dart';
import 'package:my_todo/utils/share.dart';

part 'task_card.g.dart';

@JsonSerializable(createToJson: false)
class TaskCardModel {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "icon")
  String icon;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "description")
  String description;

  @JsonKey(name: "conds", fromJson: parseCondition)
  List<ConditionItem> cond;

  TaskCardModel(this.id, this.icon, this.name, this.description, this.cond);

  factory TaskCardModel.fromJson(JsonObject json) =>
      _$TaskCardModelFromJson(json);
}

List<ConditionItem> parseCondition(List<Map> data) {
  final ret = <ConditionItem>[];
  for (var e in data) {
    ret.add(
      ConditionItem(
        type: e["want"]["type"],
        finish: e["valid"],
        id: e["want"]["id"],
      ),
    );
  }
  return ret;
}

class TaskCardCondModel {
  int type;

  bool finish;

  TaskCardCondModel(this.type, this.finish);
}

class TopicItem extends StatefulWidget {
  final String dp;
  final String name;
  final String time;
  final String msg;
  final int counter;
  final GetTopicDto model;

  const TopicItem({
    super.key,
    required this.dp,
    required this.name,
    required this.time,
    required this.msg,
    required this.counter,
    required this.model,
  });

  @override
  State<TopicItem> createState() => _TopicItemState();
}

class _TopicItemState extends State<TopicItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: const CircleAvatar(
          // backgroundImage: ,
          radius: 25,
        ),
        title: Text(
          widget.name,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          widget.msg,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 10),
            Text(
              widget.time,
              style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 11),
            ),
            const SizedBox(height: 5),
            widget.counter == 0
                ? const SizedBox()
                : Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 11,
                    minHeight: 11,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1, left: 5, right: 5),
                    child: Text(
                      "${widget.counter}",
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ],
        ),
        onTap: () {
          RouterProvider.to(
            TopicRouter.detail,
            query: "/?id=${widget.model.id}",
            arguments: widget.model,
          );
        },
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  const TaskCard({super.key, required this.model});

  final TaskCardModel model;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with AutomaticKeepAliveClientMixin {
  Random r = Random();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isLight = Theme.of(context).brightness == Brightness.light;
    var key = widget.key as ValueKey<ExpansionTileCardState>;
    var conds = widget.model.cond;

    return ExpansionTileCard(
      key: key,
      elevation: 0,
      baseColor: Colors.transparent,
      expandedColor: Colors.transparent,
      borderRadius: BorderRadius.zero,
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColorLight,
        child: SvgPicture.asset(widget.model.icon),
      ),
      title: Text(
        widget.model.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      subtitle: Text(
        widget.model.description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isLight ? Colors.black26 : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      children: [
        const Divider(thickness: 1.0, height: 1.0),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: conds.length,
              itemBuilder: (context, idx) {
                return _buildCondition(context, conds[idx]);
              },
            ),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          buttonHeight: 52.0,
          buttonMinWidth: 90.0,
          children: [
            // TODO
            IconButton(
              onPressed: () {
                RouterProvider.toTaskDetail(widget.model.id, widget.model);
              },
              icon: Icon(Icons.article, color: Colors.grey),
            ),
            // IconButton(
            //   onPressed: () {
            //     RouterProvider.viewTopicMember(widget.model.id);
            //   },
            //   icon: Icon(Icons.group, color: Colors.grey),
            // ),
            // IconButton(
            //   onPressed: () async {
            //     TodoShare.shareUri(
            //       context,
            //       Uri.parse(widget.model.inviteCode),
            //     ).then(
            //       (value) => Get.snackbar(
            //         "Clipboard",
            //         "Topic's invite code is copied on clipboard.",
            //         backgroundColor: Theme.of(context).colorScheme.primary,
            //       ),
            //     );
            //     await TodoClipboard.set(widget.model.inviteCode);
            //   },
            //   icon: Icon(Icons.share, color: Colors.grey),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildCondition(BuildContext context, ConditionItem item) {
    return InkWell(
      onTap: () {},
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.type.toString(),
              style: TextStyle(
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black,
                  dark: Colors.white,
                ),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              item.subtitle,
              style: TextStyle(
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black54,
                  dark: Colors.white,
                ),
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.task_alt,
          color: item.finish ? const Color(0xffFBC800) : Colors.grey,
        ),
        leading: Icon(item.icon()),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ConditionItem {
  late String subtitle;
  int id;
  bool finish;
  ConditionType type;

  ConditionItem({required this.id, required this.finish, required this.type}) {
    switch (type) {
      case ConditionType.click:
        subtitle = "";
      case ConditionType.qr:
        subtitle = "";
      case ConditionType.locale:
        subtitle = "";
      case ConditionType.text:
        subtitle = "";
      case ConditionType.file:
        subtitle = "";
      case ConditionType.image:
        subtitle = "";
      case ConditionType.timer:
        subtitle = "";
    }
  }

  IconData icon() {
    switch (type) {
      case ConditionType.click:
        return Icons.ads_click;
      case ConditionType.file:
        return Icons.drive_folder_upload;
      case ConditionType.qr:
        return Icons.qr_code;
      case ConditionType.locale:
        return Icons.location_on;
      case ConditionType.text:
        return Icons.abc;
      case ConditionType.image:
        return Icons.image;
      case ConditionType.timer:
        return Icons.timer;
    }
  }

  static ConditionItem random() {
    return ConditionItem(
      finish: true,
      type:
          ConditionType.values[Mock.number(
            max: ConditionType.values.length - 1,
          )],
      id: Mock.number(),
    );
  }

  static List<ConditionItem> randomList(int count) {
    // 1. 打乱 ConditionType.values
    List<ConditionType> shuffledTypes = List.of(ConditionType.values)
      ..shuffle();

    // 2. 选取 count 个唯一的 ConditionType
    List<ConditionType> selectedTypes = shuffledTypes.take(count).toList();

    // 3. 生成 ConditionItem 列表
    return selectedTypes.map((type) {
      return ConditionItem(
        finish: Mock.boolean(),
        type: type,
        id: Mock.number(),
      );
    }).toList();
  }
}

enum ConditionType {
  click,
  file,
  image,
  qr,
  locale,
  text,
  timer;

  @override
  String toString() {
    switch (this) {
      case ConditionType.click:
        return "condition_click".tr;
      case ConditionType.qr:
        return "condition_qr".tr;
      case ConditionType.locale:
        return "condition_locale".tr;
      case ConditionType.file:
        return "condition_file".tr;
      case ConditionType.text:
        return "condition_text".tr;
      case ConditionType.image:
        return "condition_image".tr;
      case ConditionType.timer:
        return "condition_timer".tr;
    }
  }

  static ConditionType fromString(String value) {
    switch (value) {
      case 'locale':
        return ConditionType.locale;
      case 'click':
        return ConditionType.click;
      case 'qr':
        return ConditionType.qr;
      case 'text':
        return ConditionType.text;
      case 'file':
        return ConditionType.file;
      default:
        throw ArgumentError('Invalid enum value: $value');
    }
  }
}
