// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/topic.dart';
import 'package:my_todo/utils/clipboard.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/topic/snapshot/topic_page.dart';

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

class TopicCard extends StatefulWidget {
  const TopicCard({super.key, required this.model});

  final Topic model;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard>
    with AutomaticKeepAliveClientMixin {
  Random r = Random();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isLight = Theme.of(context).brightness == Brightness.light;
    var key = widget.key as ValueKey<ExpansionTileCardState>;
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
        // child: Text(
        //   widget.title[0],
        //   style: const TextStyle(
        //     color: Colors.white,
        //     fontWeight: FontWeight.bold,
        //     fontSize: 16,
        //   ),
        // ),
      ),
      title: Text(
        widget.model.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      subtitle: tags(context, widget.model.tags ?? [], limit: 22),
      children: [
        const Divider(thickness: 1.0, height: 1.0),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              widget.model.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontSize: 16),
            ),
          ),
        ),
        OverflowBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                RouterProvider.viewTopicDetail(widget.model.id, widget.model);
              },
              icon: Icon(Icons.calendar_month, color: Colors.grey),
            ),
            IconButton(
              onPressed: () {
                RouterProvider.viewTopicMember(widget.model.id);
              },
              icon: Icon(Icons.group, color: Colors.grey),
            ),
            IconButton(
              onPressed: () async {
                TodoShare.shareUri(
                  context,
                  Uri.parse(widget.model.inviteCode),
                ).then(
                  (value) => Get.snackbar(
                    "clipboard".tr,
                    "topic_invite_code_copied".tr,
                  ),
                );
                await TodoClipboard.set(widget.model.inviteCode);
              },
              icon: Icon(FontAwesomeIcons.ticket, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
