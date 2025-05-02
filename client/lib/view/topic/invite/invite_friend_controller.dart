import 'package:get/get.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/chat/snapshot/chat_page.dart';

class TopicInviteController extends GetxController {
  late int id;
  RxList<ContactInfo> contacts = <ContactInfo>[].obs;
  RxSet<String> selectedContactIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    userContactsRequest().then((res) {
      for (var user in res) {
        if (user["id"] != Guard.u!.id) {
          contacts.add(
            ContactInfo(
              id: user["id"].toString(),
              name: user["name"],
              about: user["about"] ?? "",
            ),
          );
        }
      }
    });
  }

  void toggleSelection(String id) {
    if (selectedContactIds.contains(id)) {
      selectedContactIds.remove(id);
    } else {
      selectedContactIds.add(id);
    }
  }
}
