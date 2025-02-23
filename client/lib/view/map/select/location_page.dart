// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:my_todo/component/drawer/reactive_text.dart';

import 'package:my_todo/view/map/select/location_controller.dart';
import 'package:my_todo/view/map/select/place.dart';
import 'package:my_todo/view/map/select/search_model.dart';
import 'package:my_todo/utils/web_sandbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MyDrawer extends StatefulWidget {
  final Function? onOpen;
  final Function? onClose;
  final Widget child;

  const MyDrawer({super.key, this.onOpen, this.onClose, required this.child});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  void initState() {
    super.initState();
    if (widget.onOpen != null) {
      widget.onOpen!();
    }
  }

  @override
  void dispose() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: widget.child,
    );
  }
}

class LocatePage extends StatefulWidget {
  const LocatePage({super.key});

  @override
  State<LocatePage> createState() => _LocatePageState();
}

class _LocatePageState extends State<LocatePage> {
  LocationController controller = Get.find<LocationController>();
  late MyDrawer drawer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    drawer = MyDrawer(
      child: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          GestureDetector(
            child: const ReactiveText(text: "back", icon: Icons.abc),
            onTap: () {
              Get.back();
              Get.back(result: controller.pos);
            },
          ),
          GestureDetector(
            child: const ReactiveText(text: "screenshot", icon: Icons.abc),
            onTap: () {
              controller.webSandBoxController.callMethod("screenshot", null);
              Get.back();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 30),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(80),
                      bottomRight: Radius.circular(80)),
                  color: Colors.green),
              child: const Row(
                children: [
                  Icon(Icons.location_on),
                  Text(
                    "标记点",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            child: const ReactiveText(text: "标记点", icon: Icons.abc),
            onTap: () {
              // webSandBoxController.sendEvent("screenshot", "");
              controller.webSandBoxController
                  .callMethod("switchOpenMarker", null);
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildByWeb(BuildContext context) {
    Rx<bool> focus = Rx(false);
    Size size = MediaQuery.sizeOf(context);
    Widget searchBar = buildFloatingSearchBar(
        context,
        (v) {
          focus.value = v;
        },
        controller.model,
        onTap: () {
          controller.webSandBoxController.callMethod("hello", ["你好"]);
        });
    return Scaffold(
        drawerScrimColor: Colors.transparent,
        drawer:
            Obx(() => focus.value ? PointerInterceptor(child: drawer) : drawer),
        onDrawerChanged: (v) {
          focus.value = v;
        },
        body: FutureBuilder<bool>(
            future: controller.getLocation(context),
            builder: (ctx, snap) {
              if (snap.hasData) {
                return Stack(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: SizedBox(
                          height: size.height - 60,
                          child: webSandBox(controller.webSandBoxController),
                        )),
                    Obx(
                      () => focus.value
                          ? PointerInterceptor(child: searchBar)
                          : searchBar,
                    )
                  ],
                );
              }
              return Container();
            }));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildByWeb(context);
    }
    Widget searchBar =
        buildFloatingSearchBar(context, (v) {}, controller.model, onTap: () {
      controller.webSandBoxController.callMethod("hello", ["你好"]);
    });
    return Scaffold(
        drawer: drawer,
        drawerScrimColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: controller.getLocation(context),
          builder: (ctx, snap) {
            if (snap.hasData) {
              return Stack(children: [
                webSandBox(controller.webSandBoxController),
                searchBar
              ]);
            }
            return Container();
          },
        ));

    // return Scaffold(
    //     body: Stack(
    //   children: [
    //     webSandBox(webSandBoxController),
    //     buildFloatingSearchBar(context, (v) {}, model, onTap: () {
    //       print(_jsObject.callMethod('hello', ['你好']));
    //     }),
    //   ],
    // ));
  }
}

Widget buildFloatingSearchBar(
    BuildContext context, ValueChanged<bool> cb, SearchModel model,
    {required void Function() onTap}) {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  final FloatingSearchBarController controller = FloatingSearchBarController();

  return FloatingSearchBar(
    hint: 'Search...',
    scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
    transitionDuration: const Duration(milliseconds: 800),
    transitionCurve: Curves.easeInOut,
    physics: const BouncingScrollPhysics(),
    axisAlignment: isPortrait ? 0.0 : -1.0,
    openAxisAlignment: 0.0,
    width: isPortrait ? 600 : 500,
    debounceDelay: const Duration(milliseconds: 500),
    onQueryChanged: (v) {
      model.onQueryChanged(v);
    },
    onFocusChanged: cb,
    progress: model.isLoading,
    transition: CircularFloatingSearchBarTransition(),
    controller: controller,
    onKeyEvent: (KeyEvent keyEvent) {
      if (keyEvent.logicalKey == LogicalKeyboardKey.escape) {
        controller.query = '';
        controller.close();
      }
    },
    actions: [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: const Icon(Icons.place),
          onPressed: onTap,
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ],
    builder: (context, transition) => buildExpandableBody(context, model),
  );
}

Widget buildExpandableBody(BuildContext context, SearchModel model) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Obx(() => Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ImplicitlyAnimatedList<Place>(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            items: model.suggestions.value,
            insertDuration: const Duration(milliseconds: 700),
            itemBuilder: (BuildContext context, Animation<double> animation,
                Place item, _) {
              return SizeFadeTransition(
                animation: animation,
                child: buildItem(context, model, item),
              );
            },
            updateItemBuilder: (BuildContext context,
                Animation<double> animation, Place item) {
              return FadeTransition(
                opacity: animation,
                child: buildItem(context, model, item),
              );
            },
            areItemsTheSame: (Place a, Place b) => a == b,
          ),
        )),
  );
}

Widget buildItem(BuildContext context, SearchModel model, Place place) {
  final ThemeData theme = Theme.of(context);
  final TextTheme textTheme = theme.textTheme;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: () {
          model.onSelected({"lat": place.lat, "lng": place.lng});
          FloatingSearchBar.of(context)?.close();
          Future<void>.delayed(
            const Duration(milliseconds: 500),
            () => model.clear(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: model.suggestions.value == history
                      ? const Icon(Icons.history, key: Key('history'))
                      : const Icon(Icons.place, key: Key('place')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.level2Address,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      if (model.suggestions.value.isNotEmpty &&
          place != model.suggestions.value.last)
        const Divider(height: 0),
    ],
  );
}
