// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:my_todo/component/skeleton/skeleton.dart';
import 'package:my_todo/component/skeleton/stylings.dart';
import 'package:my_todo/component/skeleton/widget.dart';

class SubscribeSkeletonPage extends StatelessWidget {
  const SubscribeSkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      isLoading: true,
      skeleton: _skeletonView(),
      child: Container(),
    );
  }

  Widget _skeletonView() => SkeletonListView(
        item: SkeletonListTile(
          verticalSpacing: 12,
          leadingStyle: const SkeletonAvatarStyle(
              width: 64, height: 64, shape: BoxShape.circle),
          titleStyle: SkeletonLineStyle(
              height: 16,
              minLength: 200,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          subtitleStyle: SkeletonLineStyle(
              height: 12,
              maxLength: 200,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          hasSubtitle: true,
        ),
      );
}
