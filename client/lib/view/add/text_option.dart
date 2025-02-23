// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:my_todo/view/add/popular_filter_list.dart';

class TextOption extends StatefulWidget {
  final TaskConditionModel model;

  const TextOption({super.key, required this.model});

  @override
  State<TextOption> createState() => _TextOptionState();
}

class _TextOptionState extends State<TextOption> {
  Rx<bool> active = Rx(false);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        onTap: () {
          active.value = !active.value;
          if (widget.model.onTap != null) {
            widget.model.onTap!(active.value);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Obx(() => Icon(
                    active.value
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: active.value
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.6),
                  )),
              const SizedBox(
                width: 4,
              ),
              Text(
                widget.model.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
