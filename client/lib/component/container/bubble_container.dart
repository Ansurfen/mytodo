// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/theme/color.dart';

class BubbleContainer extends StatelessWidget {
  final Widget? child;
  final Color? backgroundColor;

  const BubbleContainer({super.key, this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: const Color(0xFF3A5160).withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: child ?? Container(),
        ),
      ),
    );
  }
}

class BubbleTextFormField extends StatelessWidget {
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const BubbleTextFormField(
      {super.key,
      this.hintText,
      this.minLines,
      this.maxLines,
      this.onChanged,
      this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          color: themeData.brightness == Brightness.light
              ? Colors.grey.withOpacity(0.2)
              : Colors.black38.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 5),
        child: Container(
            decoration: BoxDecoration(
                color: themeData.brightness == Brightness.light
                    ? Colors.white
                    : HexColor.fromInt(0x1c1c1e),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: TextFormField(
                  onChanged: onChanged,
                  minLines: minLines,
                  maxLines: maxLines,
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: hintText,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hoverColor: Colors.transparent),
                ))),
      ),
    );
  }
}

class NestedBubbleTextFormField extends StatefulWidget {
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final Widget? child;
  final bool show;
  const NestedBubbleTextFormField(
      {super.key,
      this.hintText,
      this.minLines,
      this.maxLines,
      this.onChanged,
      this.controller,
      this.child,
      required this.show});

  @override
  State<NestedBubbleTextFormField> createState() =>
      _NestedBubbleTextFormFieldState();
}

class _NestedBubbleTextFormFieldState extends State<NestedBubbleTextFormField> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          color: themeData.brightness == Brightness.light
              ? Colors.grey.withOpacity(0.2)
              : Colors.black38.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 5),
        child: Container(
            decoration: BoxDecoration(
                color: themeData.brightness == Brightness.light
                    ? Colors.white
                    : HexColor.fromInt(0x1c1c1e),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  widget.show ? widget.child ?? Container() : Container(),
                  TextFormField(
                    onChanged: widget.onChanged,
                    minLines: widget.minLines,
                    maxLines: widget.maxLines,
                    controller: widget.controller,
                    decoration: InputDecoration(
                        hintText: widget.hintText,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hoverColor: Colors.transparent),
                  )
                ]))),
      ),
    );
  }
}

class BubbleDropdown extends StatefulWidget {
  final double? width;
  final void Function()? onOpen;
  final void Function()? onClose;
  final void Function()? onTap;
  final Widget? child;
  const BubbleDropdown(
      {super.key,
      this.width,
      this.child,
      this.onTap,
      this.onOpen,
      this.onClose});

  @override
  State<BubbleDropdown> createState() => _BubbleDropdownState();
}

class _BubbleDropdownState extends State<BubbleDropdown> {
  Rx<bool> isOpen = false.obs;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return InkWell(
        onTap: widget.onTap,
        child: SizedBox(
            width: widget.width,
            child: Stack(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.light
                          ? Colors.grey.withOpacity(0.2)
                          : HexColor.fromInt(0x1c1c1e),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30.0))),
                ),
                Positioned.fill(
                    child: Container(
                  margin: const EdgeInsets.only(
                      left: 2, right: 2, top: 2, bottom: 5),
                  height: 40,
                  decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.light
                          ? Colors.white
                          : HexColor.fromInt(0x1c1c1e),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30.0))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, top: 15),
                    child: widget.child,
                  ),
                )),
                Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0, top: 10),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50))),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            size: 28,
                          )
                          // child: Obx(() => isOpen.value
                          //     ? const Icon(
                          //         Icons.close,
                          //         color: Colors.black,
                          //         size: 28,
                          //       )
                          //     : const Icon(
                          //         Icons.keyboard_arrow_down,
                          //         color: Colors.black,
                          //         size: 28,
                          //       )),
                          ),
                    ))
              ],
            )));
  }
}
