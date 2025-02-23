// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class TabIconData {
  TabIconData(
      {this.index = 0,
      this.isSelected = false,
      this.animationController,
      required this.icon});

  bool isSelected;
  int index;
  IconData icon;

  AnimationController? animationController;

  static List<TabIconData> tabIconsList = [
    TabIconData(
        index: 0,
        isSelected: true,
        animationController: null,
        icon: Icons.assignment),
    TabIconData(
        index: 1,
        isSelected: false,
        animationController: null,
        icon: Icons.topic),
    TabIconData(
        index: 2,
        isSelected: false,
        animationController: null,
        icon: Icons.wechat),
    TabIconData(
        index: 3,
        isSelected: false,
        animationController: null,
        icon: Icons.podcasts),
  ];
}
