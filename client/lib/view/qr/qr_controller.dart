// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:get/get.dart';
import 'package:my_todo/utils/net.dart';

class QRController extends GetxController {
  Rx<String> qrValue = "".obs;
  late final Timer setInterval;

  @override
  void onInit() {
    setInterval = Timer.periodic(const Duration(seconds: 10), (timer) {
      qrValue.value = DateTime.now().toString();
    });
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () async {
      await WS.init();
    });
  }

  @override
  void dispose() {
    setInterval.cancel();
    super.dispose();
  }
}
