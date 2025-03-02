// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/model/dto/task.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/topic.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/clipboard.dart';
import 'package:my_todo/utils/share.dart';

class TaskCardModel {
  int? id;
  String name;
  String topic;
  String desc;
  DateTime startAt;
  List<int> cond;

  TaskCardModel(
    this.name,
    this.topic,
    this.desc,
    this.startAt,
    this.cond, {
    this.id,
  });
}

class TaskCardOld extends StatelessWidget {
  final GetTaskDto model;

  const TaskCardOld({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    for (var i = 0; i < model.conds.length; i++) {
      if (model.conds[i] == TaskCondType.qr.index) {
        icons.add(
          Icon(Icons.crop_free, color: Theme.of(context).colorScheme.onPrimary),
        );
      } else if (model.conds[i] == TaskCondType.hand.index) {
        icons.add(
          Icon(Icons.handshake, color: Theme.of(context).colorScheme.onPrimary),
        );
      } else if (model.conds[i] == TaskCondType.locale.index) {
        icons.add(
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        );
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
        color: ThemeProvider.contrastColor(
          context,
          light: HexColor.fromInt(0xfafafa),
          dark: HexColor.fromInt(0x1c1c1e),
        ),
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
                      Text(model.name, style: const TextStyle(fontSize: 18)),
                      Text(model.topic, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Text(
                    DateFormat("yyyy/MM/dd HH:mm:ss").format(model.departure),
                  ),
                ],
              ),
              Row(children: [...icons]),
            ],
          ),
        ),
      ),
    );
  }
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
  const TaskCard({
    super.key,
    required this.title,
    required this.msg,
    required this.model,
  });

  final GetTopicDto model;
  final String title;
  final String msg;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with AutomaticKeepAliveClientMixin {
  List<Color> colors = [
    const Color(0xff8D7AEE),
    const Color(0xffF468B7),
    const Color(0xffFEC85C),
    const Color(0xff5FD0D3),
    const Color(0xffBFACAA),
  ];
  Random r = Random();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
    bool isLight = Theme.of(context).brightness == Brightness.light;
    var key = widget.key as ValueKey<ExpansionTileCardState>;
    return ExpansionTileCard(
      key: key,
      elevation: 0,
      baseColor: isLight ? Colors.grey.shade50 : HexColor.fromInt(0x1c1c1e),
      expandedColor: isLight ? Colors.grey.shade50 : HexColor.fromInt(0x1c1c1e),
      leading: CircleAvatar(
        backgroundColor: colors[r.nextInt(colors.length)],
        child: Text(
          widget.title[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      subtitle: Text(
        widget.msg,
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
            child: _buildItem(
              context,
              DataItem(
                title: 'BTC',
                subtitle: 'Bitcoin',
                price: '\$64215.10',
                changedPrice: 12.3,
                imgUrl: 'assets/image/btc.png',
              ),
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
                RouterProvider.viewTopicDetail(widget.model.id, widget.model);
              },
              icon: Icon(Icons.details, color: Theme.of(context).primaryColor),
            ),
            IconButton(
              onPressed: () {
                RouterProvider.viewTopicMember(widget.model.id);
              },
              icon: Icon(Icons.group, color: Theme.of(context).primaryColor),
            ),
            IconButton(
              onPressed: () async {
                TodoShare.shareUri(
                  context,
                  Uri.parse(widget.model.inviteCode),
                ).then(
                  (value) => Get.snackbar(
                    "Clipboard",
                    "Topic's invite code is copied on clipboard.",
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
                await TodoClipboard.set(widget.model.inviteCode);
              },
              icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, DataItem item) {
    return InkWell(
      onTap: () {},
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: Text(
            //     item.price,
            //     style: const TextStyle(
            //       color: Colors.black87,
            //       fontSize: 16,
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),
            Expanded(
              child: Text(
                '✅ ',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: item.profitColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        // trailing: Text('${item.profit}%',
        //     style: TextStyle(
        //         color: item.profitColor,
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600)),
        // leading: Image.asset(item.imgUrl, width: 32, height: 32),
        leading: Icon(Icons.location_on),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DataItem {
  String title;
  String subtitle;
  String price;
  double changedPrice;
  String imgUrl;

  DataItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.changedPrice,
    required this.imgUrl,
  });

  bool isIncrease() {
    return changedPrice > 0;
  }

  bool isDecrease() {
    return changedPrice < 0;
  }

  String get profit {
    if (isIncrease()) {
      return '+${changedPrice.toString()}';
    } else if (isDecrease()) {
      return changedPrice.toString();
    } else {
      return changedPrice.toString();
    }
  }

  Color get profitColor {
    if (isIncrease()) {
      return Colors.green;
    } else if (isDecrease()) {
      return Colors.red;
    } else {
      return Colors.grey[800]!;
    }
  }
}
