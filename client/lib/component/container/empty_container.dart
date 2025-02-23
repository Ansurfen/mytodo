// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class EmptyContainer extends StatelessWidget {
  final IconData icon;
  final String desc;
  final String what;
  final Widget child;
  final bool render;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final double? height;

  const EmptyContainer(
      {super.key,
      required this.icon,
      required this.desc,
      required this.what,
      this.onTap,
      required this.child,
      required this.render,
      this.decoration,
      this.alignment,
      this.padding,
      this.height});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return render
        ? child
        : Container(
            height: height,
            alignment: alignment,
            padding: padding,
            decoration: decoration ??
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: themeData.primaryColor,
                ),
                Text(
                  desc,
                  style: TextStyle(color: themeData.colorScheme.onPrimary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    what,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ));
  }
}
