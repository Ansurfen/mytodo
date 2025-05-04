import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/view/task/chart/task_chart_controller.dart';

class TaskChartPage extends StatefulWidget {
  const TaskChartPage({super.key});

  @override
  State<TaskChartPage> createState() => _TaskChartPageState();
}

class _TaskChartPageState extends State<TaskChartPage> {
  TaskChartController controller = Get.find<TaskChartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: todoAppBar(
        context,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text("task_progress".tr),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            // 统计信息卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "total_members".tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          controller.totalMembers.value.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "finished_members".tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          controller.finishedMembers.value.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "progress".tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          "${(controller.progress.value * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 成员列表
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Obx(
                  () => ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 所有者列表
                      if (controller.owners.isNotEmpty) ...[
                        _buildSectionHeader(context, 'owner'.tr),
                        ..._buildMemberList(context, controller.owners),
                        const Divider(),
                      ],
                      
                      // 管理员列表
                      if (controller.admins.isNotEmpty) ...[
                        _buildSectionHeader(context, 'admin'.tr),
                        ..._buildMemberList(context, controller.admins),
                        const Divider(),
                      ],
                      
                      // 普通成员列表
                      if (controller.members.isNotEmpty) ...[
                        _buildSectionHeader(context, 'member'.tr),
                        ..._buildMemberList(context, controller.members),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildMemberList(BuildContext context, List<Map<String, dynamic>> members) {
    return members.map((member) => ListTile(
      leading: GestureDetector(
        onTap: () {
          RouterProvider.toUserProfile(member['user_id']);
        },
        child: CircleAvatar(
          backgroundImage: TodoImage.userProfile(member['user_id']),
          radius: 25,
        ),
      ),
      title: Text(
        member['name'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${member['finished']}/${member['total']}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            member['finished'] == member['total']
                ? Icons.check_circle
                : Icons.check_circle_outline,
            color: member['finished'] == member['total']
                ? Colors.amber
                : Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    )).toList();
  }
}
