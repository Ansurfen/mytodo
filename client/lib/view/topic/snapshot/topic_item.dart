// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/topic.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/clipboard.dart';
import 'package:my_todo/utils/share.dart';

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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 11,
              ),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
        onTap: () {
          RouterProvider.to(TopicRouter.detail,
              query: "/?id=${widget.model.id}", arguments: widget.model);
        },
      ),
    );
  }
}

class TopicCard extends StatefulWidget {
  const TopicCard(
      {Key? key, required this.title, required this.msg, required this.model})
      : super(key: key);

  final GetTopicDto model;
  final String title;
  final String msg;

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard>
    with AutomaticKeepAliveClientMixin {
  List<Color> colors = [
    const Color(0xff8D7AEE),
    const Color(0xffF468B7),
    const Color(0xffFEC85C),
    const Color(0xff5FD0D3),
    const Color(0xffBFACAA)
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
      initialElevation: 1,
      baseColor:
          isLight ? HexColor.fromInt(0xfafafa) : HexColor.fromInt(0x1c1c1e),
      expandedColor:
          isLight ? HexColor.fromInt(0xfafafa) : HexColor.fromInt(0x1c1c1e),
      leading: CircleAvatar(
          backgroundColor: colors[r.nextInt(colors.length)],
          child: Text(widget.title[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ))),
      title: Text(widget.title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimary)),
      subtitle: Text(
        widget.msg,
        style: TextStyle(
          color: isLight ? Colors.black26 : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      children: [
        const Divider(
          thickness: 1.0,
          height: 1.0,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              """Hi there, I'm a drop-in replacement for Flutter's ExpansionTile.

Use me any time you think your app could benefit from being just a bit more Material.

These buttons control the next card down!""",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 16),
            ),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          buttonHeight: 52.0,
          buttonMinWidth: 90.0,
          children: [
            IconButton(
                onPressed: () {
                  RouterProvider.viewTopicDetail(widget.model.id, widget.model);
                },
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  RouterProvider.viewTopicMember(widget.model.id);
                },
                icon: Icon(
                  Icons.group,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () async {
                  TodoShare.shareUri(
                          context, Uri.parse(widget.model.inviteCode))
                      .then((value) => Get.snackbar("Clipboard",
                          "Topic's invite code is copied on clipboard.",
                          backgroundColor:
                              Theme.of(context).colorScheme.primary));
                  await TodoClipboard.set(widget.model.inviteCode);
                },
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).primaryColor,
                ))
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
