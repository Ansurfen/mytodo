// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final bool selected;
  final ValueChanged<bool> onChange;
  final Color? selectedColor;
  final Color? unselectedColor;

  const LikeButton({
    super.key,
    required this.icon,
    required this.selected,
    required this.onChange,
    this.selectedColor,
    this.unselectedColor,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onChange(!selected),
      icon: Icon(
        selected ? (selectedIcon ?? icon) : icon,
        color: selected ? selectedColor : unselectedColor,
      ),
    );
  }
}

LikeButton favoriteButton(
  BuildContext context, {
  bool selected = false,
  required void Function(bool) onChange,
}) {
  return LikeButton(
    icon: Icons.favorite_border,
    selectedIcon: Icons.favorite,
    selected: selected,
    unselectedColor: Theme.of(context).colorScheme.onPrimary,
    selectedColor: Theme.of(context).primaryColor,
    onChange: onChange,
  );
}
