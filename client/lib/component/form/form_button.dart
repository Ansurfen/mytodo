// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

import '../../theme/provider.dart';

class FormButton extends StatelessWidget {
  final String innerText;
  final void Function() onPressed;
  final bool? selectable;
  final double? width;
  final double? height;

  const FormButton(
      {super.key,
      required this.innerText,
      required this.onPressed,
      this.selectable,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }

  Widget _build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool _selectable = selectable ?? true;

    return Container(
      width: width ?? size.width * 0.85,
      height: height ?? size.height * 0.05,
      decoration: BoxDecoration(
        color: _selectable
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextButton(
        onPressed: _selectable ? onPressed : () {},
        child: Text(
          innerText,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary, fontSize: 20),
        ),
      ),
    );
  }
}
