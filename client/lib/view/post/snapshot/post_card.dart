// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/component/button/like_button.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/post/component/profile.dart';
import 'package:my_todo/view/post/detail/post_detail_controller.dart';
import 'package:my_todo/model/vo/post.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'images_shower.dart';

class PostCard extends StatefulWidget {
  final PostDetailModel model;
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
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            widget.model.username,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        RawChip(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Theme.of(context).primaryColorLight,
                          avatar: Icon(
                            Icons.location_on,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            "unknown".tr,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
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
                Text(widget.model.content),
                const SizedBox(height: 10),
                CareTemplateImageWidget(
                  imageList: widget.model.imageUri,
                  size: screenSize,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  Text("${widget.model.commentCnt}"),
                ],
              ),
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
                              widget.model.favoriteCnt--;
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
                              widget.model.favoriteCnt++;
                              widget.model.isFavorite = true;
                            });
                          }
                        });
                      }
                    },
                  ),
                  Text("${widget.model.favoriteCnt}"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      TodoShare.shareUri(
                        context,
                        Uri.parse("${Guard.server}/post?id=${widget.model.id}"),
                      );
                    },
                    icon: Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text("share".tr),
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
}
