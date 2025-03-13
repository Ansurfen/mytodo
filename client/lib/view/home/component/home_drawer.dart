// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/component/drawer/reactive_text.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/user.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/theme/provider.dart';

import 'package:flutter/material.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({
    super.key,
    this.screenIndex,
    this.iconAnimationController,
    this.callBackIndex,
    this.callExit,
  });

  final AnimationController? iconAnimationController;
  final DrawerIndex? screenIndex;
  final Function(DrawerIndex)? callBackIndex;
  final Function()? callExit;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList>? drawerList;
  @override
  void initState() {
    setDrawerListArray();
    super.initState();
  }

  void setDrawerListArray() {
    drawerList = [
      DrawerList(
        index: DrawerIndex.nav,
        labelName: 'home'.tr,
        icon: const Icon(Icons.home),
      ),
      DrawerList(
        index: DrawerIndex.feedback,
        labelName: 'feedback'.tr,
        icon: const Icon(Icons.help),
      ),
      DrawerList(
        index: DrawerIndex.invite,
        labelName: 'me'.tr,
        icon: const Icon(Icons.group),
      ),
      DrawerList(
        index: DrawerIndex.share,
        labelName: 'rate_the_app'.tr,
        icon: const Icon(Icons.share),
      ),
      DrawerList(
        index: DrawerIndex.about,
        labelName: 'about_us'.tr,
        icon: const Icon(Icons.info),
      ),
      DrawerList(
        index: DrawerIndex.log,
        labelName: 'logger'.tr,
        icon: const Icon(Icons.edit_note),
      ),
    ];
  }

  List<Widget> profile() {
    if (Guard.isLogin()) {
      return [
        AnimatedBuilder(
          animation: widget.iconAnimationController!,
          builder: (BuildContext context, Widget? child) {
            return ScaleTransition(
              scale: AlwaysStoppedAnimation<double>(
                1.0 - (widget.iconAnimationController!.value) * 0.2,
              ),
              child: RotationTransition(
                turns: AlwaysStoppedAnimation<double>(
                  Tween<double>(begin: 0.0, end: 24.0)
                          .animate(
                            CurvedAnimation(
                              parent: widget.iconAnimationController!,
                              curve: Curves.fastOutSlowIn,
                            ),
                          )
                          .value /
                      360,
                ),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: GestureDetector(
                    onTap: RouterProvider.viewUserEdit,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(60.0),
                      ),
                      child:
                          Guard.u == null
                              ? Container()
                              : userProfile(Guard.u!.id),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            Guard.userName(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color:
                  !ThemeProvider.isDark
                      ? const Color(0xFF3A5160)
                      : Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Text(
          'offline'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
          ),
        ),
      ),
    ];
  }

  Widget signBar() {
    if (Guard.isLogin()) {
      return ReactiveText(
        text: 'sign_out'.tr,
        icon: Icons.logout,
        onTap: onTapped,
      );
    }
    return ReactiveText(
      text: 'sign_up'.tr,
      icon: Icons.login,
      onTap: () {
        RouterProvider.offNamed(UserRouter.sign);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: profile(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 1, color: Theme.of(context).colorScheme.onSecondary),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(height: 1, color: const Color(0xFF3A5160).withOpacity(0.6)),
          ReactiveText(
            text: "GitHub",
            icon: Icons.abc,
            onTap: () async {
              await urlPicker(context, "https://github.com/Ansurfen");
            },
          ),
          Divider(height: 1, color: const Color(0xFF3A5160).withOpacity(0.6)),
          signBar(),
        ],
      ),
    );
  }

  void onTapped() {
    widget.callExit!(); // Print to console.
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index!);
        },
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 6.0,
                    height: 46.0,
                    // decoration: BoxDecoration(
                    //   color: widget.screenIndex == listData.index
                    //       ? Colors.blue
                    //       : Colors.transparent,
                    //   borderRadius: new BorderRadius.only(
                    //     topLeft: Radius.circular(0),
                    //     topRight: Radius.circular(16),
                    //     bottomLeft: Radius.circular(0),
                    //     bottomRight: Radius.circular(16),
                    //   ),
                    // ),
                  ),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  listData.isAssetsImage
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          listData.imageName,
                          color:
                              widget.screenIndex == listData.index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.onTertiary,
                        ),
                      )
                      : Icon(
                        listData.icon?.icon,
                        color:
                            widget.screenIndex == listData.index
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.onTertiary,
                      ),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      // color: widget.screenIndex == listData.index
                      //     ? Colors.black
                      //     : AppTheme.nearlyBlack,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                  animation: widget.iconAnimationController!,
                  builder: (BuildContext context, Widget? child) {
                    return Transform(
                      transform: Matrix4.translationValues(
                        (MediaQuery.of(context).size.width * 0.75 - 64) *
                            (1.0 - widget.iconAnimationController!.value - 1.0),
                        0.0,
                        0.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75 - 64,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(28),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(28),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex!(indexScreen);
  }
}

enum DrawerIndex { UNINDEX, nav, feedback, share, about, invite, Testing, log }

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
}
