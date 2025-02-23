// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/text.dart';

class ReactiveText extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function()? onTap;

  const ReactiveText(
      {super.key, required this.text, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            text,
            style: TextStyle(
              fontFamily: TodoTextStyle.fontName1,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.left,
          ),
          trailing: Icon(
            icon,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        )
      ],
    );
  }
}
