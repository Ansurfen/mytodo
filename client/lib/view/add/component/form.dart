// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class FormHeader extends StatefulWidget {
  final IconData icon;
  final String name;
  const FormHeader({super.key, required this.icon, required this.name});

  @override
  State<FormHeader> createState() => _FormHeaderState();
}

class _FormHeaderState extends State<FormHeader> {
  Widget _icon(IconData icon) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Theme.of(context).primaryColorLight.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 8)
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 32,
          width: 32,
          color: Theme.of(context).primaryColorLight.withOpacity(0.4),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _icon(widget.icon),
        const SizedBox(width: 10),
        Text(
          widget.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
