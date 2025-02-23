// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

import '../../theme/color.dart';

class FormInputField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String? Function(String?) validator;
  final bool suffixIcon;
  final bool? isDense;
  final bool obscureText;
  final Color? fontColor;
  final Color? bgColor;
  final String? value;
  final TextEditingController? textEditingController;
  final void Function(String?)? onSaved;

  const FormInputField(
      {Key? key,
      required this.labelText,
      required this.hintText,
      required this.validator,
      this.suffixIcon = false,
      this.isDense,
      this.textEditingController,
      this.obscureText = false,
      this.onSaved,
      this.fontColor,
      this.value,
      this.bgColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormInputFieldState();
}

class _FormInputFieldState extends State<FormInputField> {
  bool _obscureText = true;
  late TextEditingController _controller;

  @override
  void initState() {
    if (widget.textEditingController == null) {
      _controller = TextEditingController();
    } else {
      _controller = widget.textEditingController!;
    }
    if (widget.value != null) {
      _controller.text = widget.value!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    return Container(
      color: widget.bgColor ?? themeData.colorScheme.primary,
      width: size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.labelText,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.fontColor ?? themeData.colorScheme.onPrimary),
            ),
          ),
          TextFormField(
            cursorColor: themeData.primaryColor,
            controller: _controller,
            style: TextStyle(
              color: widget.fontColor ?? themeData.colorScheme.onPrimary,
            ),
            obscureText: (widget.obscureText && _obscureText),
            decoration: InputDecoration(
              errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent)),
              focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent)),
              errorStyle: const TextStyle(color: Colors.redAccent),
              isDense: (widget.isDense != null) ? widget.isDense : false,
              hintText: widget.hintText,
              hintStyle: TextStyle(color: HexColor("#616060")),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: themeData.primaryColorLight),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: themeData.primaryColorLight),
              ),
              suffixIcon: widget.suffixIcon
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.remove_red_eye
                            : Icons.visibility_off_outlined,
                        color: HexColor("#616060"),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              suffixIconConstraints: (widget.isDense != null)
                  ? const BoxConstraints(maxHeight: 33)
                  : null,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
            onSaved: widget.onSaved,
          ),
        ],
      ),
    );
  }
}
