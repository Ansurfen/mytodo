// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/provider.dart';

class FormTitle extends StatelessWidget {
  final String title;
  final double? fontSize;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final Color? fontColor;
  const FormTitle(
      {Key? key,
      required this.title,
      this.fontSize,
      this.left,
      this.right,
      this.top,
      this.bottom,
      this.fontColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(
        left: left ?? 0,
        right: right ?? 0,
        top: top ?? 0,
        bottom: bottom ?? 0,
      ),
      // EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 60),
      child: Text(
        title,
        style: TextStyle(
            color: fontColor ?? Theme.of(context).colorScheme.onPrimary,
            fontSize: fontSize ?? 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSerif'),
      ),
    );
  }
}
