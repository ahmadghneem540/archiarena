import 'package:get/get.dart';

import 'chat_inbox_controller.dart';

class ChatInboxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatInboxController>(() => ChatInboxController());
  }
}
