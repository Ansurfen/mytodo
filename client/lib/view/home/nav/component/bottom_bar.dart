// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/tabIcon/tabIcon_data.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/guide.dart';
import 'package:my_todo/view/home/nav/component/bottom_bar_controller.dart';
import 'package:showcaseview/showcaseview.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({super.key, this.tabIconsList, this.changeIndex});

  final Function(int index)? changeIndex;
  final List<TabIconData>? tabIconsList;
  @override
  State<BottomBarView> createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  BottomBarController controller = Get.find<BottomBarController>();

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        _tabIcons(themeData, mediaQueryData),
        Padding(
          padding: EdgeInsets.only(bottom: mediaQueryData.padding.bottom),
          child: _addButton(themeData),
        ),
      ],
    );
  }

  Widget _tabIcons(ThemeData themeData, MediaQueryData mediaQueryData) {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (BuildContext context, Widget? child) {
        return Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: PhysicalShape(
            color:
                themeData.brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
            elevation: 16.0,
            clipper: TabClipper(
              radius:
                  Tween<double>(begin: 0.0, end: 1.0)
                      .animate(
                        CurvedAnimation(
                          parent: controller.animationController,
                          curve: Curves.fastOutSlowIn,
                        ),
                      )
                      .value *
                  38.0,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 62,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                    child: Row(
                      children: [
                        _tabIcon(0),
                        _tabIcon(1),
                        Container(
                          width:
                              Tween<double>(begin: 0.0, end: 1.0)
                                  .animate(
                                    CurvedAnimation(
                                      parent: controller.animationController,
                                      curve: Curves.fastOutSlowIn,
                                    ),
                                  )
                                  .value *
                              64.0,
                        ),
                        _tabIcon(2),
                        _tabIcon(3),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: mediaQueryData.padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabIcon(int index) {
    return Expanded(
      child: TabIcons(
        tabIconData: widget.tabIconsList?[index],
        removeAllSelect: () {
          setRemoveAllSelection(widget.tabIconsList?[index]);
          widget.changeIndex!(index);
        },
      ),
    );
  }

  Widget _addButton(ThemeData themeData) {
    return SizedBox(
      width: 38 * 2.0,
      height: 38 + 62.0,
      child: Container(
        alignment: Alignment.topCenter,
        color: Colors.transparent,
        child: SizedBox(
          width: 38 * 2.0,
          height: 38 * 2.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScaleTransition(
              alignment: Alignment.center,
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: controller.animationController,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: Showcase(
                key: Guide.three,
                title: "add".tr,
                description: "guide_3".tr,
                tooltipBackgroundColor: Theme.of(context).primaryColor,
                textColor: Colors.white,
                floatingActionWidget: FloatingActionWidget(
                  left: 16,
                  bottom: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: ShowCaseWidget.of(context).dismiss,
                      child: Text(
                        'showcase_close'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                targetShapeBorder: const CircleBorder(),
                tooltipActionConfig: const TooltipActionConfig(
                  alignment: MainAxisAlignment.spaceBetween,
                  gapBetweenContentAndAction: 10,
                  position: TooltipActionPosition.outside,
                ),
                tooltipActions: [
                  TooltipActionButton(
                    name: 'showcase_previous'.tr,
                    backgroundColor: Colors.transparent,
                    type: TooltipDefaultActionType.previous,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  TooltipActionButton(
                    name: 'showcase_next'.tr,
                    type: TooltipDefaultActionType.next,
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
                onBarrierClick: () {
                  debugPrint('Barrier clicked');
                  debugPrint(
                    'Floating Action widget for first '
                    'showcase is now hidden',
                  );
                  ShowCaseWidget.of(
                    context,
                  ).hideFloatingActionWidgetForKeys([Guide.one]);
                },
                child: Container(
                  // alignment: Alignment.center,s
                  decoration: BoxDecoration(
                    color: themeData.primaryColor,
                    gradient: LinearGradient(
                      colors: [
                        themeData.primaryColor,
                        themeData.primaryColorDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: themeData.primaryColorLight.withOpacity(0.4),
                        offset: const Offset(8.0, 16.0),
                        blurRadius: 16.0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: RouterProvider.viewAdd,
                      child: Icon(
                        Icons.add,
                        color: themeData.colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setRemoveAllSelection(TabIconData? tabIconData) {
    if (!mounted) return;
    setState(() {
      widget.tabIconsList?.forEach((TabIconData tab) {
        tab.isSelected = false;
        if (tabIconData!.index == tab.index) {
          tab.isSelected = true;
        }
      });
    });
  }
}

class TabIcons extends StatefulWidget {
  const TabIcons({super.key, this.tabIconData, this.removeAllSelect});

  final TabIconData? tabIconData;
  final Function()? removeAllSelect;
  @override
  State<TabIcons> createState() => _TabIconsState();
}

class _TabIconsState extends State<TabIcons> with TickerProviderStateMixin {
  @override
  void initState() {
    widget.tabIconData?.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        widget.removeAllSelect!();
        widget.tabIconData?.animationController?.reverse();
      }
    });
    super.initState();
  }

  void setAnimation() {
    widget.tabIconData?.animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            if (!widget.tabIconData!.isSelected) {
              setAnimation();
            }
          },
          child: IgnorePointer(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                ScaleTransition(
                  alignment: Alignment.center,
                  scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                    CurvedAnimation(
                      parent: widget.tabIconData!.animationController!,
                      curve: const Interval(
                        0.1,
                        1.0,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                  ),
                  // child: Image.asset(widget.tabIconData!.isSelected
                  //     ? widget.tabIconData!.selectedImagePath
                  //     : widget.tabIconData!.imagePath),
                  child:
                      widget.tabIconData!.isSelected
                          ? Icon(
                            widget.tabIconData!.icon,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          )
                          : Icon(
                            widget.tabIconData!.icon,
                            color: Colors.grey,
                            size: 30,
                          ),
                ),
                Positioned(
                  top: 4,
                  left: 6,
                  right: 0,
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.tabIconData!.animationController!,
                        curve: const Interval(
                          0.2,
                          1.0,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 6,
                  bottom: 8,
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.tabIconData!.animationController!,
                        curve: const Interval(
                          0.5,
                          0.8,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 8,
                  bottom: 0,
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.tabIconData!.animationController!,
                        curve: const Interval(
                          0.5,
                          0.6,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabClipper extends CustomClipper<Path> {
  TabClipper({this.radius = 38.0});

  final double radius;

  @override
  Path getClip(Size size) {
    final Path path = Path();

    final double v = radius * 2;
    path.lineTo(0, 0);
    path.arcTo(
      Rect.fromLTWH(0, 0, radius, radius),
      degreeToRadians(180),
      degreeToRadians(90),
      false,
    );
    path.arcTo(
      Rect.fromLTWH(
        ((size.width / 2) - v / 2) - radius + v * 0.04,
        0,
        radius,
        radius,
      ),
      degreeToRadians(270),
      degreeToRadians(70),
      false,
    );

    path.arcTo(
      Rect.fromLTWH((size.width / 2) - v / 2, -v / 2, v, v),
      degreeToRadians(160),
      degreeToRadians(-140),
      false,
    );

    path.arcTo(
      Rect.fromLTWH(
        (size.width - ((size.width / 2) - v / 2)) - v * 0.04,
        0,
        radius,
        radius,
      ),
      degreeToRadians(200),
      degreeToRadians(70),
      false,
    );
    path.arcTo(
      Rect.fromLTWH(size.width - radius, 0, radius, radius),
      degreeToRadians(270),
      degreeToRadians(90),
      false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(TabClipper oldClipper) => true;

  double degreeToRadians(double degree) {
    final double redian = (math.pi / 180) * degree;
    return redian;
  }
}
