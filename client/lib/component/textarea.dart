// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/theme/text.dart';

class TextArea extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final int? minLines;
  final int? maxLines;

  const TextArea(
      {super.key,
      this.hintText = '',
      this.onChanged,
      this.controller,
      this.minLines,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeProvider.contrastColor(
          context,
          dark: HexColor.fromInt(0x1c1c1e),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.8),
              offset: const Offset(4, 4),
              blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(4.0),
          constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
          color: ThemeProvider.contrastColor(context,
              dark: HexColor.fromInt(0x1c1c1e)),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
            child: TextField(
              minLines: minLines,
              maxLines: maxLines,
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: TodoTextStyle.fontName1,
                fontSize: 16,
                color: ThemeProvider.contrastColor(context,
                    light: const Color(0xFF313A44),
                    dark: HexColor.fromInt(0xf5f5f5)),
              ),
              cursorColor: Colors.blue,
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: hintText),
            ),
          ),
        ),
      ),
    );
  }
}
