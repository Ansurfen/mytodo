// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/config.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/entity/image.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/model/vo/post.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/mock/post.dart' as mock;

class PostDetailController extends GetxController {
  List<MImage> images = [];
  String content = "";
  late int id;
  int selectedComment = -1;
  PostDetailModel data = PostDetailModel.empty();
  Rx<Map<int, PostComment>> comments = Rx({});
  bool showReply = false;
  final QuillController quillController = QuillController.basic();

  @override
  Future<void> onInit() async {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);
    quillController.readOnly = true;
    var res = (await postGetRequest(postId: id)) as Map<String, dynamic>;

    quillController.document = Document.fromJson(
      (res["post"]["text"] as List).map((v) {
        if (v is Map<String, dynamic> && v.containsKey("insert")) {
          var insert = v["insert"];

          if (insert is Map<String, dynamic>) {
            if (insert.containsKey("image")) {
              insert["image"] =
                  "${TodoConfig.baseUri}/post/src/${insert["image"]}";
            } else if (insert.containsKey("video")) {
              insert["video"] =
                  "${TodoConfig.baseUri}/post/src/${insert["video"]}";
            }
          }
        }
        return v;
      }).toList(),
    );

    comments.value[1] = PostComment(
      username: Mock.username(),
      createdAt: DateTime.now(),
      content: [Mock.text()],
      replies: [],
      images: [],
    );
  }

  Future fetchAll() {
    return Future.value([fetchPost(), fetchComments()]);
  }

  Future fetchPost() {
    return postDetail(PostDetailRequest(id: id)).then((res) {
      data = PostDetailModel(
        id,
        res.uid,
        res.username,
        res.isMale,
        DateTime.now(),
        res.content,
        images,
        res.favorite,
        0,
        res.isFavorite,
      );
    });
  }

  Future fetchComments() async {
    comments.value.clear();
    if (Guard.isOffline()) {
      for (var e in mock.comments) {
        comments.value[e.id] = e;
      }
    } else {
      return getPostComment(
        GetPostCommentRequest(pid: id, page: 1, pageSize: 10),
      ).then((res) {
        for (var e in res.comments) {
          comments.value[e.id] = e;
        }
      });
    }
  }

  void handleCommentReply(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            message: Column(
              children: [
                dialogAction(icon: Icons.open_in_new, text: "share".tr),
                const SizedBox(height: 15),
                dialogAction(icon: Icons.copy, text: "copy".tr),
                const SizedBox(height: 15),
                const Divider(),
                const SizedBox(height: 15),
                dialogAction(icon: Icons.warning_amber, text: "report".tr),
                const SizedBox(height: 15),
                dialogAction(icon: Icons.delete, text: "delete".tr),
              ],
            ),
          ),
    );
  }

  void handleComment(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            message: Column(
              children: [
                dialogAction(icon: Icons.open_in_new, text: "share".tr),
                const SizedBox(height: 15),
                dialogAction(icon: Icons.copy, text: "copy".tr),
                const SizedBox(height: 15),
                const Divider(),
                const SizedBox(height: 15),
                dialogAction(icon: Icons.warning_amber, text: "report".tr),
                const SizedBox(height: 15),
                dialogAction(icon: Icons.delete, text: "delete".tr),
              ],
            ),
          ),
    );
  }

  bool isCommentReply() {
    return selectedComment == -1;
  }

  void setCommentReply(int id) {
    selectedComment = id;
    showReply = true;
  }

  void clearCommentReply() {
    selectedComment = -1;
    showReply = false;
  }

  void setReplyReply(String id) {}

  void freeReplyReply() {}

  Future postMessage(String msg) async {
    if (!isCommentReply()) {
      return postAddComment(
        PostAddCommentRequest(id: id, reply: 0, content: msg),
      ).then((res) {
        int id = int.parse(res.id);
        comments.value[id] = PostComment(
          content: [msg],
          id: id,
          images: [],
          username: "",
          createdAt: DateTime.now(),
          replies: [],
        );
      });
    } else {
      return postAddCommentReply(
        PostAddCommentReplyRequest(id: selectedComment, reply: 0, content: msg),
      ).then((res) {
        int id = int.parse(res.id);
        if (comments.value[id]?.replies == null) {
          comments.value[id]?.replies = [];
        }
        comments.value[id]?.replies.add(
          PostComment(
            content: [msg],
            id: id,
            images: [],
            username: "",
            createdAt: DateTime.now(),
            replies: [],
          ),
        );
      });
    }
  }

  Future commentFavorite(int id) async {
    return postCommentFavorite(PostCommentFavoriteRequest(id: id));
  }
}
