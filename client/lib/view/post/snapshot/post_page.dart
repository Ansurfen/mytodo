// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/view/post/snapshot/post_card.dart';
import 'package:my_todo/model/vo/post.dart';
import 'package:my_todo/view/post/snapshot/post_snapshot_controller.dart';

class PostSnapshotPage extends StatefulWidget {
  const PostSnapshotPage({super.key});

  @override
  State<StatefulWidget> createState() => _PostSnapshotPageState();
}

class _PostSnapshotPageState extends State<PostSnapshotPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  PostSnapshotController controller = Get.find<PostSnapshotController>();

  Widget _postCardSpace() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16), // 让分割线缩进
      child: Divider(
        color: ThemeProvider.contrastColor(
          context,
          light: Colors.grey.shade300,
          dark: CupertinoColors.systemGrey,
        ),
        thickness: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          settingWidget(),
          const SizedBox(width: 10),
          multiWidget(context),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onTertiary,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: UnderlineTabIndicator(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          tabs: [Tab(text: "post_me".tr), Tab(text: "post_friend".tr)],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: TabBarView(
        controller: controller.tabController,
        children: [_me(), _friend()],
      ),
    );
  }

  Widget _me() {
    return refreshContainer(
      context: context,
      onLoad: () {},
      onRefresh: controller.fetch,
      child: Obx(
        () => EmptyContainer(
          icon: Icons.rss_feed,
          desc: "not post, clicks + button to create on bottom bar",
          what: "what is post?",
          render: controller.data.value.isNotEmpty,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: MediaQuery.sizeOf(context).height * 0.35,
          ),
          onTap: () {
            showTipDialog(context, content: "what_is_post".tr);
          },
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: ListView.separated(
              itemCount: controller.data.value.length,
              itemBuilder: (BuildContext context, int index) {
                return PostCard(
                  more: () {
                    controller.handlePost(context);
                  },
                  model: PostDetailModel.fromDto(controller.data.value[index]),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return _postCardSpace();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _find() {
    return refreshContainer(
      context: context,
      onLoad: () {},
      onRefresh: () {},
      child: Obx(
        () => EmptyContainer(
          icon: Icons.rss_feed,
          desc: "not post, clicks + button to create on bottom bar",
          what: "what is post?",
          render: controller.data.value.isNotEmpty,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: MediaQuery.sizeOf(context).height * 0.35,
          ),
          onTap: () {
            showTipDialog(context, content: "what_is_post".tr);
          },
          child: ListView.separated(
            itemCount: controller.data.value.length,
            itemBuilder: (BuildContext context, int index) {
              return PostCard(
                more: () {
                  controller.handlePost(context);
                },
                model: PostDetailModel.fromDto(controller.data.value[index]),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return _postCardSpace();
            },
          ),
        ),
      ),
    );
  }

  Widget _friend() {
    return refreshContainer(
      context: context,
      onLoad: () {},
      onRefresh: () {},
      child: Obx(
        () => EmptyContainer(
          icon: Icons.rss_feed,
          desc: "not post, clicks + button to create on bottom bar",
          what: "what is post?",
          render: controller.data.value.isNotEmpty,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: MediaQuery.sizeOf(context).height * 0.35,
          ),
          onTap: () {
            showTipDialog(context, content: "what_is_post".tr);
          },
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: ListView.separated(
              itemCount: controller.data.value.length,
              itemBuilder: (BuildContext context, int index) {
                return PostCard(
                  more: () {
                    controller.handlePost(context);
                  },
                  model: PostDetailModel.fromDto(controller.data.value[index]),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return _postCardSpace();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
