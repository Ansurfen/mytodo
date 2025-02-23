// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';

class FadeAnimatedBuilder extends StatelessWidget {
  final AnimationController animation;
  final Animation<double> opacity;
  final Widget child;

  const FadeAnimatedBuilder(
      {super.key,
      required this.animation,
      required this.opacity,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, c) {
          return FadeTransition(
            opacity: opacity,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 30 * (1.0 - opacity.value), 0.0),
              child: child,
            ),
          );
        });
  }
}
