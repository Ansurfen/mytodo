// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class FileArea extends StatefulWidget {
  final List<String> files;

  const FileArea({super.key, required this.files});

  @override
  State<FileArea> createState() => _FileAreaState();
}

class _FileAreaState extends State<FileArea> {
  List<Widget> widgets = [];
  List<bool> removes = [];

  @override
  void initState() {
    for (int i = 0; i < widget.files.length; i++) {
      widgets.add(
        RawChip(
            backgroundColor: Theme.of(context).primaryColorLight,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            avatar: Icon(
              Icons.file_copy_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              widget.files[i],
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onDeleted: () {
              widgets.removeAt(i);
              removes[i] = true;
              setState(() {});
            },
            deleteButtonTooltipMessage: '删除',
            deleteIcon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.primary,
            )),
      );
      removes.add(false);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FileArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.files.remove("");
    widgets.clear();
    for (int i = 0; i < oldWidget.files.length; i++) {
      bool available = oldWidget.files[i].isNotEmpty;
      if (available) {
        widgets.add(
          RawChip(
              backgroundColor: Theme.of(context).primaryColorLight,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              avatar: Icon(
                Icons.file_copy_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                widget.files[i],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              deleteIcon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.primary,
              ),
              deleteButtonTooltipMessage: '删除',
              onDeleted: () {
                widgets[i] = Container();
                oldWidget.files[i] = "";
                setState(() {});
              }),
        );
      } else {
        widgets.add(Container());
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [...widgets],
    );
  }
}
