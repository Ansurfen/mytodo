// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math';
import 'package:flutter/material.dart';
import 'shimmer.dart';
import 'stylings.dart';

class SkeletonItem extends StatelessWidget {
  final Widget child;
  const SkeletonItem({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    if (Shimmer.of(context) == null) {
      return ShimmerWidget(
        child: _SkeletonWidget(
          isLoading: true, skeleton: child,
          //  child: SizedBox()
        ),
      );
    }
    return child;
  }
}

class _SkeletonWidget extends StatefulWidget {
  const _SkeletonWidget({
    Key? key,
    required this.isLoading,
    required this.skeleton,
    // required this.child,
  }) : super(key: key);

  final bool isLoading;
  final Widget skeleton;
  // final Widget child;

  @override
  __SkeletonWidgetState createState() => __SkeletonWidgetState();
}

class __SkeletonWidgetState extends State<_SkeletonWidget> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    if (widget.isLoading) {
      setState(() {
        // update the shimmer painting.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (!widget.isLoading) {
    //   return widget.child;
    // }

    // Collect ancestor shimmer info.
    final shimmer = Shimmer.of(context)!;
    if (!shimmer.isSized) {
      // The ancestor Shimmer widget has not laid
      // itself out yet. Return an empty box.
      return const SizedBox();
    }
    final shimmerSize = shimmer.size;
    final gradient = shimmer.currentGradient;

    if (context.findRenderObject() == null) return const SizedBox();

    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: context.findRenderObject() as RenderBox,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.skeleton,
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final SkeletonAvatarStyle style;
  const SkeletonAvatar({Key? key, this.style = const SkeletonAvatarStyle()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Padding(
        padding: style.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: ((style.randomWidth != null && style.randomWidth!) ||
                      (style.randomWidth == null &&
                          (style.minWidth != null && style.maxWidth != null)))
                  ? doubleInRange(
                      style.minWidth ??
                          ((style.maxWidth ?? constraints.maxWidth) / 3),
                      style.maxWidth ?? constraints.maxWidth)
                  : style.width,
              height: ((style.randomHeight != null && style.randomHeight!) ||
                      (style.randomHeight == null &&
                          (style.minHeight != null && style.maxHeight != null)))
                  ? doubleInRange(
                      style.minHeight ??
                          ((style.maxHeight ?? constraints.maxHeight) / 3),
                      style.maxHeight ?? constraints.maxHeight)
                  : style.height,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: style.shape,
                borderRadius:
                    style.shape != BoxShape.circle ? style.borderRadius : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final SkeletonLineStyle style;
  const SkeletonLine({Key? key, this.style = const SkeletonLineStyle()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Align(
        alignment: style.alignment,
        child: Padding(
            // padding: style.randomLength
            //     ? EdgeInsetsDirectional.only(
            //         end: 0.0 +
            //             Random().nextInt(
            //                 (MediaQuery.of(context).size.width / 2).round()))
            padding: style.padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: ((style.randomLength != null && style.randomLength!) ||
                          (style.randomLength == null &&
                              (style.minLength != null &&
                                  style.maxLength != null)))
                      ? doubleInRange(
                          style.minLength ??
                              ((style.maxLength ?? constraints.maxWidth) / 3),
                          style.maxLength ?? constraints.maxWidth)
                      : style.width,
                  height: style.height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: style.borderRadius,
                  ),
                );
              },
            )),
      ),
    );
  }
}

class SkeletonParagraph extends StatelessWidget {
  final SkeletonParagraphStyle style;

  const SkeletonParagraph({
    Key? key,
    this.style = const SkeletonParagraphStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Padding(
        padding: style.padding,
        child: Column(
          children: [
            for (var i = 1; i <= style.lines; i++) ...[
              SkeletonLine(
                style: style.lineStyle,
              ),
              if (i != style.lines)
                SizedBox(
                  height: style.spacing,
                )
            ]
          ],
        ),
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final SkeletonAvatarStyle? leadingStyle;
  final SkeletonLineStyle? titleStyle;
  final bool hasSubtitle;
  final SkeletonLineStyle? subtitleStyle;
  final EdgeInsetsGeometry? padding;
  final double? contentSpacing;
  final double? verticalSpacing;
  final Widget? trailing;

  // final SkeletonListTileStyle style;

  SkeletonListTile({
    Key? key,
    this.hasLeading = true,
    this.leadingStyle, //  = const SkeletonAvatarStyle(padding: EdgeInsets.all(0)),
    this.titleStyle = const SkeletonLineStyle(
      padding: EdgeInsets.all(0),
      height: 22,
    ),
    this.subtitleStyle = const SkeletonLineStyle(
      height: 16,
      padding: EdgeInsetsDirectional.only(end: 32),
    ),
    this.hasSubtitle = false,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.contentSpacing = 8,
    this.verticalSpacing = 8,
    this.trailing,
  }) : super(key: key);
  // : assert(height >= lineHeight + spacing + (padding?.vertical ?? 16) + 2);

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLeading)
              SkeletonAvatar(
                style: leadingStyle ?? const SkeletonAvatarStyle(),
              ),
            SizedBox(
              width: contentSpacing,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SkeletonLine(
                    style: titleStyle ?? const SkeletonLineStyle(),
                  ),
                  if (hasSubtitle) ...[
                    SizedBox(
                      height: verticalSpacing,
                    ),
                    SkeletonLine(
                      style: subtitleStyle ?? const SkeletonLineStyle(),
                    ),
                  ]
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class SkeletonListView extends StatelessWidget {
  final Widget? item;
  final Widget Function(BuildContext, int)? itemBuilder;
  final int? itemCount;
  final bool scrollable;
  final EdgeInsets? padding;
  final double? spacing;

  SkeletonListView({
    Key? key,
    this.item,
    this.itemBuilder,
    this.itemCount,
    this.scrollable = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: ListView.builder(
        padding: padding,
        physics: scrollable ? null : NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder ??
            (context, index) =>
                item ??
                SkeletonListTile(
                  hasSubtitle: true,
                ),
      ),
    );
  }
}

double doubleInRange(num start, num end) =>
    Random().nextDouble() * (end - start) + start;
