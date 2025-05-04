import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/view/post/snapshot/post_card.dart';
import 'package:my_todo/view/post/snapshot/post_snapshot_controller.dart';

class PostFriendPage extends StatefulWidget {
  const PostFriendPage({super.key});

  @override
  State<PostFriendPage> createState() => _PostFriendPageState();
}

class _PostFriendPageState extends State<PostFriendPage> {
  PostSnapshotController controller = Get.find<PostSnapshotController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.grey.shade50,
                dark: CupertinoColors.darkBackgroundGray,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.paperPlane,
                  color: Colors.grey.shade200,
                  size: 36,
                ),
                Container(width: 10),
                Text("一句话形容你当下的心情"),
              ],
            ),
          ),
        ),
        Expanded(
          child: refreshContainer(
            context: context,
            onLoad: () {},
            onRefresh: () {},
            child: Obx(
              () => EmptyContainer(
                icon: Icons.rss_feed,
                desc: "not post, clicks + button to create on bottom bar",
                what: "what is post?",
                render: controller.postFriendData.value.isNotEmpty,
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
                    itemCount: controller.postFriendData.value.length,
                    itemBuilder: (BuildContext context, int index) {
                      var post = controller.postFriendData.value[index];
                      return PostCard(
                        more: () {
                          controller.actionByFriend(context, post);
                        },
                        model: post,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
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
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
