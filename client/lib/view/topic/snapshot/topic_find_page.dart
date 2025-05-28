import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/view/topic/snapshot/topic_controller.dart';
import 'package:my_todo/view/topic/snapshot/topic_page.dart';

import '../../../utils/dialog.dart';

class TopicFindPage extends StatefulWidget {
  const TopicFindPage({super.key});

  @override
  State<TopicFindPage> createState() => _TopicFindPageState();
}

class _TopicFindPageState extends State<TopicFindPage> {
  TopicSnapshotController controller = Get.find<TopicSnapshotController>();

  @override
  Widget build(BuildContext context) {
    return refreshContainer(
      context: context,
      onRefresh: controller.fetchTopicFind,
      onLoad: controller.loadTopicFind,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SearchTextField(fieldValue: (v) {}),
            ),
            Obx(
              () => EmptyContainer(
                height: MediaQuery.sizeOf(context).height * 0.75,
                icon: Icons.rss_feed,
                desc: "no_topic".tr,
                what: "what_is_topic".tr,
                render: controller.topicFind.isNotEmpty,
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  top: MediaQuery.sizeOf(context).height * 0.35,
                ),
                onTap: () {
                  showTipDialog(context, content: "what_is_topic_desc".tr);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: FadeAnimatedBuilder(
                    animation: controller.animationController,
                    opacity: TodoAnimateStyle.fadeOutOpacity(
                      controller.animationController,
                    ),
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.topicFind.length,
                      itemBuilder: (context, index) {
                        TopicFind tf = controller.topicFind[index];
                        return InkWell(
                          onTap: () => showTopicDetail(context, tf),
                          child: TopicFindItem(
                            model: TopicFindItemModel(
                              icon: tf.icon,
                              name: tf.name,
                              description: tf.description,
                              tags: tf.tags ?? [],
                              memberCount: tf.memberCount,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 0.5,
                            width: MediaQuery.of(context).size.width / 1.3,
                            child: Divider(
                              color: ThemeProvider.contrastColor(
                                context,
                                light: Colors.grey,
                                dark: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void showTopicDetail(BuildContext context, TopicFind topic) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击外部不能关闭弹窗
      builder: (BuildContext context) {
        return CustomDialog(model: topic);
      },
    );
  }
}
