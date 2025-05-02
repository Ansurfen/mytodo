import 'package:get/get.dart';
import 'package:my_todo/view/topic/invite/invite_friend_controller.dart';

class TopicInviteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TopicInviteController());
  }
}