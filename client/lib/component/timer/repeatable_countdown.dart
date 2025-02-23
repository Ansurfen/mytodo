// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class RepeatableCountdown extends StatefulWidget {
  final int total;
  final Widget Function(int count) countingWidget;
  final Widget freeWidget;

  const RepeatableCountdown({
    super.key,
    required this.total,
    required this.countingWidget,
    required this.freeWidget,
  });

  @override
  State<RepeatableCountdown> createState() => _RepeatableCountdownState();
}

class _RepeatableCountdownState extends State<RepeatableCountdown> {
  Rx<int> count = 0.obs;
  Rx<bool> finish = true.obs;
  Timer? _timer;
  int _countdownTime = 0;

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_countdownTime == 0) {
          setState(() {
            _countdownTime = 60;
          });
          startCountdownTimer();
        }
      },
      child: _countdownTime != 0
          ? widget.countingWidget(_countdownTime)
          : widget.freeWidget,
    );
  }

  void startCountdownTimer() {
    const oneSec = Duration(seconds: 1);

    callback(Timer timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _timer?.cancel();
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }
}
