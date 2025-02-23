// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class ShadowButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final Icon? icon;
  final Size? size;
  final TextStyle? textStyle;

  const ShadowButton(
      {super.key,
      this.onTap,
      this.text = '',
      this.icon,
      this.size,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size?.width ?? 120,
      height: size?.height ?? 40,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              offset: const Offset(4, 4),
              blurRadius: 8.0),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon ?? Container(),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    text,
                    style: textStyle ??
                        const TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
