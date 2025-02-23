// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/hook/post.dart';
import 'package:my_todo/model/dto/post.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/model/vo/post.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/pagination.dart';

class PostSnapshotController extends GetxController
    with GetTickerProviderStateMixin {
  Rx<List<GetPostDto>> data = Rx([]);
  late StreamSubscription<Post> _uploadPost;
  late TabController tabController;
  Pagination<GetPostDto> pagination = Pagination(index: 1);

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    Future.delayed(Duration.zero, fetch);
    _uploadPost = PostHook.subscribeSnapshot(onData: (post) {
      data.value.add(PostDetailModel(0, 0, Guard.userName(), true,
          DateTime.timestamp(), post.content, [], 0, 0, false));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _uploadPost.cancel();
  }

  Future fetch() async {
    return getPost(GetPostRequest(pagination.index(), pagination.getLimit()))
        .then((res) {
      // data.value = res.data;
      // data.refresh();
      pagination.setData(res.data);
      pagination.refresh();
    }).catchError((err) {
      showError(err);
    });
  }

  void handlePost(BuildContext context) {
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
}
