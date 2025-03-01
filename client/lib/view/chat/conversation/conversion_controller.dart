// Copyright 2025 The mytodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:my_todo/model/user.dart';
import 'package:video_player/video_player.dart';

class ConversionController extends GetxController {
  Map<String, VideoPlayerController> videoplayers = {};
  late Chatsnapshot chatsnapshot;

  @override
  void onInit() {
    super.onInit();
    chatsnapshot = Get.arguments;
  }

  @override
  void dispose() {
    videoplayers.forEach((k, v) {
      v.dispose();
    });
    super.dispose();
  }
}
