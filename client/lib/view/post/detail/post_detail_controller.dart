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
import 'package:my_todo/model/entity/image.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/model/post.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';

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
  Rx<bool> isFavorite = false.obs;
  Rx<int> likeCount = 0.obs;

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
    isFavorite.value = data.value.isFavorite;
    likeCount.value = data.value.likeCount;
    await fetchComments();
    update();
  }

  void updateFavorite(bool isFavorite) {
    this.isFavorite.value = isFavorite;
    likeCount.value += isFavorite ? 1 : -1;
  }

  int total = 0;
  Future fetchComments() async {
    comments.value.clear();
    if (Guard.isOffline()) {
      // for (var e in mock.comments) {
      //   comments.value[e.id] = e;
      // }
    } else {
      postCommentGetRequest(postId: id, page: 1, pageSize: 10).then((res) {
        if (res["comments"] != null) {
          for (var e in res["comments"]) {
            PostComment comment = PostComment.fromJson(e);
            if (comment.replyId == 0) {
              comments.value[comment.id] = comment;
            } else {
              comments.value[comment.replyId]?.replies.add(comment);
            }
          }
        }
        total = res["total"];
        comments.refresh();
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
    if (isCommentReply()) {
      return postCommentNewRequest(postId: id, replyId: 0, text: msg).then((
        cid,
      ) {
        comments.value[cid] = PostComment(
          text: msg,
          id: cid,
          username: Guard.userName(),
          createdAt: DateTime.now(),
          replies: [],
          postId: id,
          userId: Guard.u!.id,
          replyId: 0,
        );
        comments.refresh();
      });
    } else {
      return postCommentNewRequest(
        postId: id,
        replyId: selectedComment,
        text: msg,
      ).then((res) {
        Guard.log.i(res);
      });
    }
  }

  Future commentFavorite(int id) async {
    return postCommentLikeRequest(postId: id, commentId: id);
  }

  Future commentReplyCard(int id) async {
    if (replies.isNotEmpty) {
      replies.clear();
    }
    return postCommentReplyGetRequest(
      postId: this.id,
      commentId: id,
      page: 1,
      pageSize: 10,
    ).then((res) {
      if (res["replies"] != null) {
        // 创建一个临时map来存储所有评论
        Map<int, PostComment> commentMap = {};

        // 首先将所有评论放入map中
        for (var e in res["replies"]) {
          PostComment comment = PostComment.fromJson(e);
          commentMap[comment.id] = comment;
        }

        // 构建评论树
        for (var comment in commentMap.values) {
          if (comment.replyId == id) {
            // 这是直接回复，添加到replies中
            if (replies[comment.replyId] == null) {
              replies[comment.replyId] = [];
            }
            comment.replyName = "";
            replies[comment.replyId]?.add(comment);
          } else {
            // 这是子回复，找到其父评论并添加
            var parentId = comment.replyId;
            while (parentId != id) {
              var parent = commentMap[parentId];
              if (parent == null) break;
              parentId = parent.replyId;
            }
            if (parentId == id) {
              // 找到了根评论，添加到对应的replies中
              if (replies[parentId] == null) {
                replies[parentId] = [];
              }
              replies[parentId]?.add(comment);
            }
          }
        }
        replies.refresh();
      }
    });
  }

  RxMap<int, List<PostComment>> replies = <int, List<PostComment>>{}.obs;
}
