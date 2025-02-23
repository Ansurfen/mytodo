// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class LightButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final TextStyle? textStyle;
  final double? height;
  final double? width;

  const LightButton(
      {super.key,
      this.onTap,
      required this.text,
      this.textStyle,
      this.height,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
          onTap: onTap,
          child: Container(
            height: height ?? 48,
            width: width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(16.0),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    offset: const Offset(1.1, 1.1),
                    blurRadius: 10.0),
              ],
            ),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.left,
                style: textStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
              ),
            ),
          )),
    );
  }
}
