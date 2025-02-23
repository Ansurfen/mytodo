// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/checkbox.dart';

class ColorfulRadio extends StatelessWidget {
  final String value;
  final String groupValue;
  final void Function(String? value)? onChanged;
  final Color backgroundColor;

  const ColorfulRadio(
      {super.key,
      required this.value,
      required this.groupValue,
      this.onChanged,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Radio(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        fillColor: CheckBoxStyle.fillColor(context, color: backgroundColor));
  }
}
