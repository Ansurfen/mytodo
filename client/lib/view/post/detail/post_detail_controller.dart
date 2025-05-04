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
import 'package:my_todo/model/post.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/mock/post.dart' as mock;

class PostDetailController extends GetxController {
  List<MImage> images = [];
  String content = "";
  late int id;
  int selectedComment = -1;
  Rx<PostDetail> data =
      PostDetail(
        id: 0,
        uid: 0,
        createdAt: DateTime.now(),
        username: "",
        about: "",
        likeCount: 0,
        visitCount: 0,
        isMale: false,
        title: "",
        text: [],
        isFavorite: false,
      ).obs;
  Rx<Map<int, PostComment>> comments = Rx({});
  bool showReply = false;
  final QuillController quillController = QuillController.basic();

  @override
  Future<void> onInit() async {
    super.onInit();
    id = int.parse(Get.parameters["id"]!);
    quillController.readOnly = true;
    var res = (await postDetailRequest(id: id)) as Map<String, dynamic>;

    data.value = PostDetail.fromJson(res);
    

    quillController.document = Document.fromJson(
      (data.value.text).map((v) {
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
    update();
    comments.value[1] = PostComment(
      username: Mock.username(),
      createdAt: DateTime.now(),
      content: [Mock.text()],
      replies: [],
      images: [],
    );
  }

  void updateFavorite(bool isFavorite) {
    data.value.isFavorite = isFavorite;
    data.value.likeCount += isFavorite ? 1 : -1;
    update();
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
