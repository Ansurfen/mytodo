import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/utils/guard.dart';

class TaskChartController extends GetxController {
  var totalMembers = 0.obs;
  var finishedMembers = 0.obs;
  var progress = 0.0.obs;
  var members = <Map<String, dynamic>>[].obs;
  late int taskId; // 新增 topicId 属性

  @override
  void onInit() {
    super.onInit();
    taskId = int.parse(Get.parameters['id']!);
    Future.delayed(Duration.zero, () async {
      await fetchStats();
    });
  }

  Future<void> fetchStats() async {
    try {
      final response = await taskStatsRequest(taskId);
      Guard.log.i("Response data: $response");
      
      if (response['stats'] != null) {
        totalMembers.value = response['stats']['total_members'];
        finishedMembers.value = response['stats']['finished_members'];
        progress.value = response['stats']['progress'].toDouble();
      }
      
      if (response['members'] != null) {
        final List<dynamic> membersList = response['members'];
        members.value = membersList.map((item) => {
          'user_id': item['user_id'],
          'name': item['name'],
          'finished': item['finished'],
          'total': item['total'],
          'commit_at': item['commit_at'],
        }).toList();
      }
      
      Guard.log.i("Processed members: ${members.value}");
    } catch (e) {
      Guard.log.e("Failed to fetch stats: $e");
    }
  }
}
