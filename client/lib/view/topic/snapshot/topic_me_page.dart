import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/view/topic/snapshot/topic_controller.dart';
import 'package:my_todo/view/topic/snapshot/topic_item.dart';
import 'package:my_todo/view/topic/snapshot/topic_page.dart';

class TopicMePage extends StatefulWidget {
  const TopicMePage({super.key});

  @override
  State<TopicMePage> createState() => _TopicMePageState();
}

class _TopicMePageState extends State<TopicMePage> {
  TopicSnapshotController controller = Get.find<TopicSnapshotController>();

  @override
  Widget build(BuildContext context) {
    return refreshContainer(
      context: context,
      onRefresh: () {
        controller.freshTopic();
      },
      onLoad: () {},
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
                render: controller.topics____.value.isNotEmpty,
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  top: MediaQuery.sizeOf(context).height * 0.35,
                ),
                onTap: () {
                  showTipDialog(context, content: "what_is_topic".tr);
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
                      itemCount: controller.topics.length,
                      itemBuilder: (context, index) {
                        final ValueKey<ExpansionTileCardState> k = ValueKey(
                          ExpansionTileCardState(),
                        );
                        return TopicCard(
                          key: k,
                          model: controller.topics[index],
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
}
