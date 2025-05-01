// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/view/add/add_post_page.dart';
import 'package:my_todo/view/map/locate/locate_page.dart';
import 'package:my_todo/view/task/detail/task_detail_controller.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';
import 'package:path/path.dart' as path;

class TaskInfoPage extends StatefulWidget {
  const TaskInfoPage({super.key});

  @override
  State<TaskInfoPage> createState() => _TaskInfoPageState();
}

class _TaskInfoPageState extends State<TaskInfoPage>
    with TickerProviderStateMixin {
  TaskInfoController controller = Get.find<TaskInfoController>();
  Rx<List<Widget>> imageWidgets = Rx([]);
  Rx<Widget> body = Rx(Container());
  late TabController _tabController;
  final double infoHeight = 700.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: const Interval(0, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    setData();

    _tabController = TabController(
      length: controller.model.cond.length,
      vsync: this,
    );
    super.initState();
  }

  Future setData() async {
    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabViews = [];
    List<Widget> tabs = List.generate(controller.model.cond.length, (idx) {
      var cond = controller.model.cond[idx];
      switch (cond.type) {
        case ConditionType.click:
          tabViews.add(TaskClickPage());
        case ConditionType.qr:
          tabViews.add(TaskQRPage());
        case ConditionType.locale:
          tabViews.add(
            MapLocatePage(taskId: controller.model.id, condId: cond.id),
          );
        case ConditionType.text:
          tabViews.add(TaskTextPage());
        case ConditionType.file:
          tabViews.add(TaskFilePage());
        case ConditionType.image:
          // TODO: Handle this case.
          throw UnimplementedError();
        case ConditionType.timer:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
      return Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cond.icon(), color: Theme.of(context).colorScheme.onPrimary),
            SizedBox(width: 6),
            Text(
              cond.type.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      );
    });
    return todoScaffold(
      context,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(Mock.username()),
        actions: [
          IconButton(
            onPressed: () async {
              // TODO toast

              await taskCommitRequest(
                taskId: controller.model.id,
                condId: controller.model.cond[_tabController.index].id,
                argument: {
                  "doc":
                      controller.quillController!.document.toDelta().toList(),
                },
              );
            },
            icon: Icon(Icons.cloud_upload),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: tabs,
          indicator: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ), // 只显示边框
            borderRadius: BorderRadius.circular(30), // 让边框有圆角
            color: Colors.transparent, // 确保背景透明
          ),
        ),
      ),
      body: TabBarView(controller: _tabController, children: tabViews),
    );
  }
}

class TaskClickPage extends StatefulWidget {
  const TaskClickPage({super.key});

  @override
  State<TaskClickPage> createState() => _TaskClickPage();
}

class _TaskClickPage extends State<TaskClickPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset('assets/images/click.svg'),
        TextButton(
          onPressed: () {},
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: lighten(Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class TaskFilePage extends StatefulWidget {
  const TaskFilePage({super.key});

  @override
  State<TaskFilePage> createState() => _TaskFilePage();
}

class _TaskFilePage extends State<TaskFilePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TaskTextPage extends StatefulWidget {
  const TaskTextPage({super.key});

  @override
  State<TaskTextPage> createState() => _TaskTextPage();
}

class _TaskTextPage extends State<TaskTextPage> {
  TaskInfoController controller = Get.find<TaskInfoController>();

  final FocusNode editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.initTextService();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: controller.quillController!,
            config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              showClipboardPaste: true,
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: const Icon(Icons.add_alarm_rounded),
                  onPressed: () {
                    controller.quillController!.document.insert(
                      controller.quillController!.selection.extentOffset,
                      TimeStampEmbed(DateTime.now().toString()),
                    );
                    controller.quillController!.updateSelection(
                      TextSelection.collapsed(
                        offset:
                            controller.quillController!.selection.extentOffset +
                            1,
                      ),
                      ChangeSource.local,
                    );
                  },
                ),
              ],
              buttonOptions: QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  afterButtonPressed: () {
                    final isDesktop = {
                      TargetPlatform.linux,
                      TargetPlatform.windows,
                      TargetPlatform.macOS,
                    }.contains(defaultTargetPlatform);
                    if (isDesktop) {
                      editorFocusNode.requestFocus();
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: QuillEditor(
              focusNode: editorFocusNode,
              scrollController: editorScrollController,
              controller: controller.quillController!,
              config: QuillEditorConfig(
                placeholder: 'Start writing your notes...',
                padding: const EdgeInsets.all(16),
                embedBuilders: [
                  ...FlutterQuillEmbeds.editorBuilders(
                    imageEmbedConfig: QuillEditorImageEmbedConfig(
                      imageProviderBuilder: (context, imageUrl) {
                        // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                        if (imageUrl.startsWith('assets/')) {
                          return AssetImage(imageUrl);
                        }
                        return null;
                      },
                    ),
                    videoEmbedConfig: QuillEditorVideoEmbedConfig(
                      customVideoBuilder: (videoUrl, readOnly) {
                        // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                        return null;
                      },
                    ),
                  ),
                  TimeStampEmbedBuilder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskLocalePage extends StatefulWidget {
  const TaskLocalePage({super.key});

  @override
  State<TaskLocalePage> createState() => _TaskLocalePage();
}

class _TaskLocalePage extends State<TaskLocalePage> {
  @override
  Widget build(BuildContext context) {
    // return MapLocatePage();
    return Container();
  }
}

class TaskQRPage extends StatefulWidget {
  const TaskQRPage({super.key});

  @override
  State<TaskQRPage> createState() => _TaskQRPage();
}

class _TaskQRPage extends State<TaskQRPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
