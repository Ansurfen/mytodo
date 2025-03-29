// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/component/button/like_button.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/post/component/profile.dart';
import 'package:my_todo/view/post/detail/post_detail_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class PostCard extends StatefulWidget {
  final Post model;
  final VoidCallback more;

  const PostCard({super.key, required this.model, required this.more});

  @override
  State<StatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  userProfile(
                    isMale: widget.model.isMale,
                    id: widget.model.uid,
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.model.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(height: 5),
                        Text(
                          DateFormat(
                            "yyyy-MM-dd HH:mm:ss",
                          ).format(widget.model.createAt),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: widget.more,
                icon: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Get.lazyPut(() => PostDetailController());
              RouterProvider.toPostDetail(widget.model.id);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(encodeText(widget.model.text)),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "浏览${widget.model.visitCount}次",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Container(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      Text(
                        "unknown".tr,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      favoriteButton(
                        context,
                        selected: widget.model.isFavorite,
                        onChange: (v) {
                          if (widget.model.isFavorite) {
                            postUnFavorite(
                              PostUnFavoriteRequest(id: widget.model.id),
                            ).then((res) {
                              if (res.success) {
                                setState(() {
                                  widget.model.likeCount--;
                                  widget.model.isFavorite = false;
                                });
                              }
                            });
                          } else {
                            postFavorite(
                              PostFavoriteRequest(id: widget.model.id),
                            ).then((res) {
                              if (res.success) {
                                setState(() {
                                  widget.model.likeCount++;
                                  widget.model.isFavorite = true;
                                });
                              }
                            });
                          }
                        },
                      ),
                      Text("${widget.model.likeCount}"),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          RouterProvider.toPostDetail(widget.model.id);
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Text("${widget.model.commentCount}"),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          TodoShare.shareUri(
                            context,
                            Uri.parse(
                              "${Guard.server}/post?id=${widget.model.id}",
                            ),
                          );
                        },
                        icon: Icon(
                          FontAwesomeIcons.share,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String text = 'abc';
  String subject = 'aaa';
  String uri = '';
  List<String> imageNames = [];
  List<String> imagePaths = [];
  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    if (uri.isNotEmpty) {
      await Share.shareUri(Uri.parse(uri));
    } else if (imagePaths.isNotEmpty) {
      final files = <XFile>[];
      for (var i = 0; i < imagePaths.length; i++) {
        files.add(XFile(imagePaths[i], name: imageNames[i]));
      }
      await Share.shareXFiles(
        files,
        text: text,
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } else {
      await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  void _onShareWithResult(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    ShareResult shareResult;
    if (imagePaths.isNotEmpty) {
      final files = <XFile>[];
      for (var i = 0; i < imagePaths.length; i++) {
        files.add(XFile(imagePaths[i], name: imageNames[i]));
      }
      shareResult = await Share.shareXFiles(
        files,
        text: text,
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } else {
      shareResult = await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
    scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
  }

  void _onShareXFileFromAssets(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final data = await rootBundle.load('assets/flutter_logo.png');
    final buffer = data.buffer;
    final shareResult = await Share.shareXFiles([
      XFile.fromData(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        name: 'flutter_logo.png',
        mimeType: 'image/png',
      ),
    ], sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);

    scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
  }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Share result: ${result.status}"),
          if (result.status == ShareResultStatus.success)
            Text("Shared to: ${result.raw}"),
        ],
      ),
    );
  }

  String encodeText(List text) {
    String ret = "";
    var delta = Document.fromJson(text).toDelta();
    for (var op in delta.toList()) {
      if (op.isInsert) {
        if (op.data is String) {
          ret += (op.data as String).replaceAll(r'\n', '\n');
        } else if (op.data is Map) {
          Map<String, dynamic> data = op.data as Map<String, dynamic>;
          if (data.containsKey("image")) {
            ret += "[IMAGE]";
          } else if (data.containsKey("video")) {
            ret += "[VIDEO]";
          }
        }
      }
    }

    return ret;
  }
}
