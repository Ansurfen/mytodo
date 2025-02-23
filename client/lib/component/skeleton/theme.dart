// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class SkeletonTheme extends InheritedWidget {
  final LinearGradient? shimmerGradient;
  final LinearGradient? darkShimmerGradient;
  final ThemeMode? themeMode;

  const SkeletonTheme({
    Key? key,
    required Widget child,
    this.shimmerGradient,
    this.darkShimmerGradient,
    this.themeMode,
  }) : super(key: key, child: child);

  static SkeletonTheme? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SkeletonTheme>();

  @override
  bool updateShouldNotify(SkeletonTheme oldWidget) =>
      oldWidget.themeMode != themeMode ||
          oldWidget.shimmerGradient != shimmerGradient ||
          oldWidget.darkShimmerGradient != darkShimmerGradient;
}