import 'package:get/get.dart';
import 'package:my_todo/view/user/sign/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
