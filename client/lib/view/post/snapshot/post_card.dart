// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/component/button/like_button.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/post/component/profile.dart';
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
  Rx<bool> isLike = false.obs;
  Rx<int> likeCount = 0.obs;

  @override
  void initState() {
    super.initState();
    isLike.value = widget.model.isFavorite;
    likeCount.value = widget.model.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    String text = encodeText(widget.model.text);
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
              RouterProvider.toPostDetail(widget.model.id);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(text), const SizedBox(height: 10)],
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
                      Obx(
                        () => favoriteButton(
                          context,
                          selected: isLike.value,
                          onChange: (v) {
                            postLikeRequest(postId: widget.model.id).then((ok) {
                              if (ok != null) {
                                isLike.value = ok;
                                likeCount.value += ok ? 1 : -1;
                              }
                            });
                          },
                        ),
                      ),
                      Obx(() => Text("${likeCount.value}")),
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
                        onPressed: () => TodoShare.share(text),
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
            ret += "post_image".tr;
          } else if (data.containsKey("video")) {
            ret += "post_video".tr;
          }
        }
      }
    }

    return ret;
  }
}
