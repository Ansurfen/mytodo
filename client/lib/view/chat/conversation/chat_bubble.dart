// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';

class ChatBubble extends StatefulWidget {
  final String message, time, username, type, replyText, replyName;
  final bool isMe, isGroup, isReply;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.time,
      required this.isMe,
      this.isGroup = false,
      this.username = "",
      required this.type,
      required this.replyText,
      required this.isReply,
      required this.replyName});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  Color chatBubbleColor() {
    if (widget.isMe) {
      return ThemeProvider.contrastColor(context,
          light: HexColor.fromInt(0xf5f5f5), dark: HexColor.fromInt(0x1c1c1e));
    }
    return Theme.of(context).primaryColorLight;
  }

  Color chatBubbleReplyColor() {
    if (widget.isMe) {
      return ThemeProvider.contrastColor(context,
          light: Colors.grey.withOpacity(0.2), dark: Colors.grey[50]!);
    }
    return Theme.of(context).primaryColor.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final align =
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = widget.isMe
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
            children: [
              widget.isMe
                  ? const SizedBox()
                  : widget.isGroup
                      ? Padding(
                          padding: const EdgeInsets.only(right: 48.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.username,
                              style: const TextStyle(
                                fontSize: 13,
                                // color: colors[rNum],
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        )
                      : const SizedBox(),
              widget.isGroup
                  ? widget.isMe
                      ? const SizedBox()
                      : const SizedBox(height: 5)
                  : const SizedBox(),
              widget.isReply
                  ? Container(
                      decoration: BoxDecoration(
                        color: chatBubbleReplyColor(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 25,
                        maxHeight: 100,
                        minWidth: 80,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.isMe ? "You" : widget.replyName,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.replyText,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                                  fontSize: 10.0,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(width: 2.0),
              widget.isReply ? const SizedBox(height: 5) : const SizedBox(),
              Padding(
                padding: EdgeInsets.all(widget.type == "text" ? 5 : 0),
                child: widget.type == "text"
                    ? !widget.isReply
                        ? Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.isMe
                                  ? ThemeProvider.contrastColor(context,
                                      light: Colors.black, dark: Colors.white)
                                  : Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                            ),
                          )
                        : Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: widget.isMe
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                              ),
                            ),
                          )
                    : Image.asset(
                        widget.message,
                        height: 130,
                        width: MediaQuery.of(context).size.width / 1.3,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: widget.isMe
              ? const EdgeInsets.only(right: 10, bottom: 10.0)
              : const EdgeInsets.only(left: 10, bottom: 10.0),
          child: Text(
            widget.time,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 10.0,
            ),
          ),
        ),
      ],
    );
  }
}
