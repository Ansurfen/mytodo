// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final bool selected;
  final ValueChanged<bool> onChange;
  final Color? selectedColor;
  final Color? unselectedColor;

  const LikeButton(
      {super.key,
      required this.icon,
      required this.selected,
      required this.onChange,
      this.selectedColor,
      this.unselectedColor,
      this.selectedIcon});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool selected = false;
  late IconData selectedIcon;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
    if (widget.selectedIcon != null) {
      selectedIcon = widget.selectedIcon!;
    } else {
      selectedIcon = widget.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          setState(() {
            selected = !selected;
            widget.onChange(selected);
          });
        },
        icon: selected
            ? Icon(
                selectedIcon,
                color: widget.selectedColor,
              )
            : Icon(
                widget.icon,
                color: widget.unselectedColor,
              ));
  }
}

LikeButton favoriteButton(BuildContext context,
    {bool selected = false, required void Function(bool) onChange}) {
  return LikeButton(
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
      selected: selected,
      unselectedColor: Theme.of(context).colorScheme.onPrimary,
      selectedColor: Theme.of(context).primaryColor,
      onChange: onChange);
}
