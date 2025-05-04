// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/hook/post.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/pagination.dart';

class PostSnapshotController extends GetxController
    with GetTickerProviderStateMixin {
  Rx<List<Post>> postMeData = Rx([]);
  Rx<List<Post>> postFriendData = Rx([]);
  late StreamSubscription<Post> _uploadPost;
  late TabController tabController;
  Pagination<Post> pagination = Pagination();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    tabController.addListener(() async {
      if (tabController.index == 0 && tabController.indexIsChanging) {
        var res = await postMeRequest();
        if (res["data"] == null) {
          return;
        }
        for (var e in (res["data"] as List)) {
          postMeData.value.add(Post.fromJson(e)..username = Guard.userName());
        }
        postMeData.refresh();
      } else {
        fetchFriend();
      }
    });
    if (Guard.isDevMode()) {
    } else {
      Future.delayed(Duration.zero, () {
        fetchFriend();
      });
      _uploadPost = PostHook.subscribeSnapshot(onData: (post) {});

      postVisitorsRequest().then((res) {
        Guard.log.i(res);
      });
      postHistoryRequest().then((res) {
        Guard.log.i(res);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _uploadPost.cancel();
  }

  Future fetchFriend() async {
    postFriendData.value.clear();
    var res = await postFriendRequest(page: 1, limit: 10);
    if (res == null) {
      return;
    }
    for (var e in (res as List)) {
      postFriendData.value.add(Post.fromJson(e));
    }
    postFriendData.refresh();
  }

  Future fetch() async {
    postMeData.value.clear();
    var res = await postMeRequest();
    for (var e in (res["data"] as List)) {
      postMeData.value.add(Post.fromJson(e)..username = Guard.userName());
    }
    postMeData.refresh();
  }

  void handlePost(BuildContext context) {
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

  void actionByFriend(BuildContext context, Post post) {
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
              ],
            ),
          ),
    );
  }
}
