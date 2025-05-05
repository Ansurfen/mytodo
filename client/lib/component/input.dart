// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'container/bubble_container.dart';

class TodoInputController {
  TextEditingController msgController;
  TextEditingController searchController;
  ValueNotifier<bool> emojiShowing = ValueNotifier<bool>(false);
  bool isSearchFocused = false;
  final ScrollController searchScrollController = ScrollController();
  final FocusNode searchFocusNode = FocusNode();
  List<Emoji> searchResults = List.empty();
  late Config config;
  OverlayEntry? overlay;

  TodoInputController(this.msgController, this.searchController);

  void closeSkinToneDialog() {
    overlay?.remove();
    overlay = null;
  }

  void dispose() {
    msgController.dispose();
    searchController.dispose();
    searchScrollController.dispose();
    searchFocusNode.dispose();
  }

  void showEmojiBar() {
    emojiShowing.value = !emojiShowing.value;
  }

  void defaultConfig(BuildContext context) {
    config = Config(
      emojiViewConfig: EmojiViewConfig(
        buttonMode: ButtonMode.MATERIAL,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      categoryViewConfig: CategoryViewConfig(
        indicatorColor: Theme.of(context).primaryColor,
        iconColorSelected: Theme.of(context).primaryColor,
        backspaceColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class TodoInput extends StatefulWidget {
  final TodoInputController controller;
  final ValueChanged<String> onTap;
  final Widget? child;
  final bool showChild;

  const TodoInput({
    super.key,
    required this.controller,
    required this.onTap,
    this.child,
    required this.showChild,
  });

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: widget.controller.showEmojiBar,
            icon: Icon(
              Icons.emoji_emotions,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        Flexible(
          child: NestedBubbleTextFormField(
            hintText: 'type_message'.tr,
            maxLines: null,
            controller: widget.controller.msgController,
            show: widget.showChild,
            child: widget.child,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () {
              widget.onTap(widget.controller.msgController.text);
              widget.controller.msgController.text = "";
              setState(() {});
            },
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class TodoInputView extends StatefulWidget {
  final TodoInputController controller;
  final GlobalKey<EmojiPickerState> state;
  final double maxWidth;
  const TodoInputView({
    super.key,
    required this.controller,
    required this.state,
    required this.maxWidth,
  });

  @override
  State<TodoInputView> createState() => _TodoInputViewState();
}

class _TodoInputViewState extends State<TodoInputView> {
  @override
  Widget build(BuildContext context) {
    final emojiSize = widget.controller.config.emojiViewConfig.getEmojiSize(
      widget.maxWidth,
    );
    // emojiSize is the size of the font, need some paddings around
    final cellSize = emojiSize + 20.0;
    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.emojiShowing,
      builder: (context, value, _) {
        return Offstage(
          offstage: !value,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller.searchController,
            builder: (context, value, _) {
              return Column(
                children: [
                  if (value.text.isEmpty && !widget.controller.isSearchFocused)
                    SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        key: widget.state,
                        textEditingController: widget.controller.msgController,
                        config: widget.controller.config,
                        onBackspacePressed: () {
                          EmojiPickerUtils().clearRecentEmojis(
                            key: widget.state,
                          );
                        },
                      ),
                    )
                  else
                    _buildSearchResults(context, emojiSize, cellSize),
                  _buildSearchBar(context, value.text.isEmpty),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isEmpty) {
    return ColoredBox(
      color: widget.controller.config.emojiViewConfig.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!widget.controller.isSearchFocused)
            IconButton(
              onPressed: widget.controller.searchFocusNode.requestFocus,
              icon: const Icon(Icons.search),
              visualDensity: VisualDensity.compact,
            )
          else
            IconButton(
              onPressed: () {
                widget.controller.searchController.text = '';
                widget.controller.searchFocusNode.unfocus();
              },
              icon: const Icon(Icons.arrow_back),
              visualDensity: VisualDensity.compact,
            ),
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  widget.controller.isSearchFocused = hasFocus;
                });
              },
              child: TextField(
                controller: widget.controller.searchController,
                focusNode: widget.controller.searchFocusNode,
                maxLines: 1,
                onChanged: (text) async {
                  widget.controller.searchResults = await EmojiPickerUtils()
                      .searchEmoji(text, defaultEmojiSet);
                  setState(() {});
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 10.0,
                  ),
                  isDense: true,
                  suffixIconConstraints: const BoxConstraints(),
                  suffixIcon:
                      isEmpty
                          ? null
                          : IconButton(
                            onPressed: () {
                              widget.controller.searchController.text = '';
                            },
                            icon: const Icon(Icons.clear),
                            visualDensity: VisualDensity.compact,
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    double emojiSize,
    double cellSize,
  ) {
    if (widget.controller.searchResults.isEmpty) {
      return SizedBox(
        height: cellSize,
        child: Center(
          child: Text(
            widget.controller.searchController.text.isEmpty
                ? 'Type your search phrase'
                : 'No matches',
          ),
        ),
      );
    }
    return SizedBox(
      height: cellSize,
      child: ListView(
        controller: widget.controller.searchScrollController,
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < widget.controller.searchResults.length; i++)
            SizedBox(
              width: cellSize,
              child: EmojiCell.fromConfig(
                emoji: widget.controller.searchResults[i],
                emojiSize: emojiSize,
                onEmojiSelected: (category, emoji) {
                  widget.controller.closeSkinToneDialog();
                  _onEmojiSelected(category, emoji);
                },
                onSkinToneDialogRequested:
                    (offest, emoji, emojiSize, categoryEmoji) =>
                        _openSkinToneDialog(
                          context,
                          emoji,
                          emojiSize,
                          categoryEmoji,
                          i,
                        ),
                config: widget.controller.config,
                emojiBoxSize: widget.controller.config.emojiViewConfig
                    .getEmojiBoxSize(widget.maxWidth),
              ),
            ),
        ],
      ),
    );
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final text = widget.controller.msgController.text;
    final selection = widget.controller.msgController.selection;
    final cursorPosition =
        widget.controller.msgController.selection.base.offset;

    if (cursorPosition < 0) {
      widget.controller.msgController.text += emoji.emoji;
      return;
    }
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji.emoji,
    );
    final emojiLength = emoji.emoji.length;
    widget.controller.msgController
      ..text = newText
      ..selection = selection.copyWith(
        baseOffset: selection.start + emojiLength,
        extentOffset: selection.start + emojiLength,
      );
  }

  void _openSkinToneDialog(
    BuildContext context,
    Emoji emoji,
    double emojiSize,
    CategoryEmoji? categoryEmoji,
    int index,
  ) {
    widget.controller.closeSkinToneDialog();
    if (!emoji.hasSkinTone ||
        !widget.controller.config.skinToneConfig.enabled) {
      return;
    }
    widget.controller.overlay = _buildSkinToneOverlay(
      context,
      emoji,
      emojiSize,
      index,
    );
    Overlay.of(context).insert(widget.controller.overlay!);
  }

  /// Overlay for SkinTone
  OverlayEntry _buildSkinToneOverlay(
    BuildContext context,
    Emoji emoji,
    double emojiSize,
    int index,
  ) {
    // Calculate position for skin tone dialog
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final emojiSpace =
        renderBox.size.width / widget.controller.config.emojiViewConfig.columns;
    final leftOffset = _getLeftOffset(emojiSpace, index);
    final left = offset.dx + index * emojiSpace + leftOffset;
    final top = offset.dy;

    // Generate other skintone options
    final skinTonesEmoji =
        SkinTone.values
            .map(
              (skinTone) => EmojiPickerUtils().applySkinTone(emoji, skinTone),
            )
            .toList();

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: 4.0,
              child: EmojiContainer(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                color:
                    widget
                        .controller
                        .config
                        .skinToneConfig
                        .dialogBackgroundColor,
                buttonMode: widget.controller.config.emojiViewConfig.buttonMode,
                child: Row(
                  children: [
                    _buildSkinToneEmoji(emoji, emojiSpace, emojiSize),
                    _buildSkinToneEmoji(
                      skinTonesEmoji[0],
                      emojiSpace,
                      emojiSize,
                    ),
                    _buildSkinToneEmoji(
                      skinTonesEmoji[1],
                      emojiSpace,
                      emojiSize,
                    ),
                    _buildSkinToneEmoji(
                      skinTonesEmoji[2],
                      emojiSpace,
                      emojiSize,
                    ),
                    _buildSkinToneEmoji(
                      skinTonesEmoji[3],
                      emojiSpace,
                      emojiSize,
                    ),
                    _buildSkinToneEmoji(
                      skinTonesEmoji[4],
                      emojiSpace,
                      emojiSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // Build Emoji inside skin tone dialog
  Widget _buildSkinToneEmoji(Emoji emoji, double width, double emojiSize) {
    return SizedBox(
      width: width,
      height: width,
      child: EmojiCell.fromConfig(
        emoji: emoji,
        emojiSize: emojiSize,
        onEmojiSelected: (category, emoji) {
          _onEmojiSelected(category, emoji);
          widget.controller.closeSkinToneDialog();
        },
        config: widget.controller.config,
        emojiBoxSize: widget.controller.config.emojiViewConfig.getEmojiBoxSize(
          widget.maxWidth,
        ),
      ),
    );
  }

  // Calucates the offset from the middle of selected emoji to the left side
  // of the skin tone dialog
  // Case 1: Selected Emoji is close to left border and offset needs to be
  // reduced
  // Case 2: Selected Emoji is close to right border and offset needs to be
  // larger than half of the whole width
  // Case 3: Enough space to left and right border and offset can be half
  // of whole width
  double _getLeftOffset(double emojiWidth, int column) {
    var remainingColumns =
        widget.controller.config.emojiViewConfig.columns -
        (column + 1 + (kSkinToneCount ~/ 2));
    if (column >= 0 && column < 3) {
      return -1 * column * emojiWidth;
    } else if (remainingColumns < 0) {
      return -1 *
          ((kSkinToneCount ~/ 2 - 1) + -1 * remainingColumns) *
          emojiWidth;
    }
    return -1 * ((kSkinToneCount ~/ 2) * emojiWidth) + emojiWidth / 2;
  }
}
