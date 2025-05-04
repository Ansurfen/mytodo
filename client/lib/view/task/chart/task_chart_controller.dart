import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/model/topic.dart';
import 'package:my_todo/utils/guard.dart';

class TaskChartController extends GetxController {
  var totalMembers = 0.obs;
  var finishedMembers = 0.obs;
  var progress = 0.0.obs;
  var owners = <Map<String, dynamic>>[].obs;
  var admins = <Map<String, dynamic>>[].obs;
  var members = <Map<String, dynamic>>[].obs;
  late int taskId;

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
        
        // 清空现有列表
        owners.clear();
        admins.clear();
        members.clear();
        
        // 按角色分组
        for (var item in membersList) {
          final member = {
            'user_id': item['user_id'],
            'name': item['name'],
            'finished': item['finished'],
            'total': item['total'],
            'commit_at': item['commit_at'],
            'role': item['role'],
          };
          
          if (member['role'] == TopicRole.owner.index) {
            owners.add(member);
          } else if (member['role'] == TopicRole.admin.index) {
            admins.add(member);
          } else {
            members.add(member);
          }
        }
      }
      
      Guard.log.i("Processed members: ${owners.length} owners, ${admins.length} admins, ${members.length} members");
    } catch (e) {
      Guard.log.e("Failed to fetch stats: $e");
    }
  }
}
