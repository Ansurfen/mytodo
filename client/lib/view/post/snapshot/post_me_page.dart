import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:my_todo/view/post/snapshot/post_card.dart';
import 'package:my_todo/view/post/snapshot/post_page.dart';
import 'package:my_todo/view/post/snapshot/post_snapshot_controller.dart';
import 'package:my_todo/view/task/snapshot/task_page.dart';

class PostMePage extends StatefulWidget {
  const PostMePage({super.key});

  @override
  State<PostMePage> createState() => _PostMePageState();
}

class _PostMePageState extends State<PostMePage> {
  final TextEditingController startDateController = TextEditingController();
  Rx<DateTime> startDate = DateTime.now().obs;
  PostSnapshotController controller = Get.find<PostSnapshotController>();

  @override
  Widget build(BuildContext context) {
    startDateController.text = DateFormat('MM/dd/yyyy').format(DateTime.now());

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    Mock.number().toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("post".tr, style: TextStyle(color: Colors.grey)),
                ],
              ),
              Column(
                children: [
                  Text(
                    Mock.number().toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("comment".tr, style: TextStyle(color: Colors.grey)),
                ],
              ),
              InkWell(
                onTap: () {
                  List<UserView> users = List.generate(
                    Mock.number(min: 5, max: 100),
                    (idx) {
                      return UserView(
                        id: idx,
                        name: Mock.username(),
                        time: Mock.dateTime(),
                      );
                    },
                  );
                  showSheetBottom(
                    context,
                    title: "views".tr,
                    child: Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (ctx, idx) {
                          final user = users[idx];
                          final date = DateFormat(
                            'MM/dd/yyyy',
                          ).format(user.time);
                          final time = DateFormat('HH:mm:ss').format(user.time);

                          // 判断是否需要显示日期标题
                          bool showDateHeader =
                              idx == 0 ||
                              DateFormat(
                                    'MM/dd/yyyy',
                                  ).format(users[idx - 1].time) !=
                                  date;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 仅当是新的日期时，显示日期标题
                              if (showDateHeader)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    bottom: 4,
                                    top: 8,
                                  ),
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: ThemeProvider.contrastColor(
                                    context,
                                    light: Colors.grey.shade50,
                                    dark: CupertinoColors.darkBackgroundGray,
                                  ),
                                ),
                                child: ListTile(
                                  leading: InkWell(
                                    onTap: () {
                                      RouterProvider.toUserProfile(user.id);
                                    },
                                    child: CircleAvatar(),
                                  ),
                                  title: Text(
                                    user.name,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  trailing: Text(
                                    time, // 只显示时间
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(height: 5);
                        },
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      Mock.number().toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("views".tr, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    Mock.number().toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("history".tr, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${startDate.value.year}${"year".tr}${startDate.value.month}${"month".tr}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    DateTime? dateTime = await todoSelectDate(
                      context,
                      initialDate: startDate.value,
                    );
                    if (dateTime != null) {
                      startDate.value = dateTime;
                    }
                  },
                  icon: Icon(
                    Icons.calendar_month,
                    color: ThemeProvider.contrastColor(
                      context,
                      light: Colors.black,
                      dark: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: refreshContainer(
            context: context,
            onLoad: () {},
            onRefresh: controller.fetchMe,
            child: Obx(
              () => EmptyContainer(
                icon: Icons.rss_feed,
                desc: "not post, clicks + button to create on bottom bar",
                what: "what is post?",
                render: controller.postMeData.value.isNotEmpty,
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
                    itemCount: controller.postMeData.value.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = controller.postMeData.value[index];
                      return PostCard(
                        more: () {
                          controller.handlePost(context, post);
                        },
                        model: post,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return _postCardSpace();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(height: 60),
      ],
    );
  }

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
}
