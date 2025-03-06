// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/model/entity/chat.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/time.dart';
import 'package:video_player/video_player.dart';

class ChatContainer extends StatefulWidget {
  final Chat data;

  const ChatContainer({super.key, required this.data});

  @override
  State<ChatContainer> createState() => _ChatContainerState();
}

class _ChatContainerState extends State<ChatContainer> {
  late bool isMe;
  List<Widget> children = [];
  VideoPlayerController? videoPlayerController;

  Color chatBubbleColor() {
    if (isMe) {
      return ThemeProvider.contrastColor(context,
          light: HexColor.fromInt(0xf5f5f5), dark: HexColor.fromInt(0x1c1c1e));
    }
    return Theme.of(context).primaryColorLight;
  }

  Color chatBubbleReplyColor() {
    if (isMe) {
      return ThemeProvider.contrastColor(context,
          light: Colors.grey.withOpacity(0.2), dark: Colors.grey[50]!);
    }
    return Theme.of(context).primaryColor.withOpacity(0.1);
  }

  Widget textSection(String msg) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        msg,
        style: TextStyle(
          color: isMe
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  Widget imageSection(String url) {
    return GestureDetector(
      onTap: () {
        RouterProvider.toPhoto(type: PhotoType.img, url: url);
      },
      child: Image(
        image: NetworkImage(url),
      ),
    );
  }

  Widget videoSection(String url) {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize();
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(5.0),
          constraints: const BoxConstraints(
            maxWidth: double.infinity,
            minWidth: 20.0,
          ),
          decoration: BoxDecoration(
              color: ThemeProvider.contrastColor(context,
                  light: HexColor.fromInt(0xf5f5f5),
                  dark: HexColor.fromInt(0x1c1c1e)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(10.0),
              )),
          child: SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoPlayer(videoPlayerController!),
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    children.clear();
    isMe = widget.data.from == Guard.user;
    for (var e in widget.data.content) {
      if (e.length > 4) {
        int type = int.parse(e.substring(0, 4));
        String metadata = e.substring(4);
        switch (type) {
          case 1:
            children.add(
              textSection(metadata),
            );
          case 2:
            children.add(imageSection(metadata));
          case 3:
            children.add(videoSection(metadata));
        }
      } else {
        children.add(textSection(""));
      }
    }
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: chatBubbleColor(),
            borderRadius: radius,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.3,
            minWidth: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          ),
        ),
        Padding(
          padding: isMe
              ? const EdgeInsets.only(right: 10, bottom: 10.0)
              : const EdgeInsets.only(left: 10, bottom: 10.0),
          child: Text(
            widget.data.time != null
                ? formatTimeDifference(widget.data.time!)
                : "",
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 10.0,
            ),
          ),
        )
      ],
    );
  }
}
