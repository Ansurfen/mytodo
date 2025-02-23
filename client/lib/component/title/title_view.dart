// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/color.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final void Function()? onTap;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  const TitleView(
      {Key? key,
      this.titleTxt = "",
      this.subTxt = "",
      this.onTap,
      this.icon,
      this.iconSize,
      this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titleTxt,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: StatisticTableTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                letterSpacing: 0.5,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Text(
                    subTxt,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: StatisticTableTheme.fontName,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    width: 26,
                    child: Icon(
                      icon ?? Icons.arrow_forward,
                      color: iconColor ?? Theme.of(context).colorScheme.onPrimary,
                      size: iconSize ?? 18,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
