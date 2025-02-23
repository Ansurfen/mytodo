// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/post.dart';
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
  String selectedComment = '';
  PostDetailModel data = PostDetailModel.empty();
  Rx<Map<String, PostComment>> comments = Rx({});
  bool showReply = false;

  @override
  void onInit() {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);
  }

  Future fetchAll() {
    return Future.value([fetchPost(), fetchComments()]);
  }

  Future fetchPost() {
    return postDetail(PostDetailRequest(id: id)).then((res) {
      data = PostDetailModel(id, res.uid, res.username, res.isMale,
          DateTime.now(), res.content, images, res.favorite, 0, res.isFavorite);
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
              GetPostCommentRequest(pid: id, page: 1, pageSize: 10))
          .then((res) {
        for (var e in res.comments) {
          comments.value[e.id] = e;
        }
      });
    }
  }

  void handleCommentReply(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
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
            ));
  }

  void handleComment(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
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
            ));
  }

  bool isCommentReply() {
    return selectedComment.isNotEmpty;
  }

  void setCommentReply(String id) {
    selectedComment = id;
    showReply = true;
  }

  void freeCommentReply() {
    selectedComment = '';
    showReply = false;
  }

  void setReplyReply(String id) {}

  void freeReplyReply() {}

  Future postMessage(String msg) async {
    if (!isCommentReply()) {
      return postAddComment(
              PostAddCommentRequest(id: id, reply: 0, content: msg))
          .then((res) {
        comments.value[res.id] = PostComment(
            content: [msg],
            id: res.id,
            images: [],
            username: "",
            createdAt: DateTime.now(),
            replies: []);
      });
    } else {
      return postAddCommentReply(PostAddCommentReplyRequest(
              id: selectedComment, reply: 0, content: msg))
          .then((res) {
        if (comments.value[res.id]?.replies == null) {
          comments.value[res.id]?.replies = [];
        }
        comments.value[res.id]?.replies.add(PostComment(
            content: [msg],
            id: res.id,
            images: [],
            username: "",
            createdAt: DateTime.now(),
            replies: []));
      });
    }
  }

  Future commentFavorite(String id) async {
    return postCommentFavorite(PostCommentFavoriteRequest(id: id));
  }
}
