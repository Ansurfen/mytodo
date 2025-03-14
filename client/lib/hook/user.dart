import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_todo/utils/guard.dart';

class UserHook {
  static StreamSubscription<Image> subscribeProfile({
    ValueChanged<Image>? onData,
  }) {
    return Guard.eventBus.on<Image>().listen(onData);
  }

  static void updateProfile(Image v) {
    Guard.eventBus.fire(v);
  }
}
