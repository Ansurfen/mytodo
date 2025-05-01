// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/component/container/bubble_container.dart';
import 'package:my_todo/component/button/light_button.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/component/textarea.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/permission.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/web_sandbox.dart';
import 'package:my_todo/view/add/add_post_page.dart';
import 'package:my_todo/view/map/locate/locate_page.dart';
import 'package:my_todo/view/task/detail/task_detail_controller.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
            onPressed: () {
              // TODO toast
              showTipDialog(context, content: "refresh success");
              debugPrint("refresh submit");
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

    final double tempHeight =
        MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Column(
            children: [
              AspectRatio(
                aspectRatio: 1.2,
                // child: Image.asset('assets/design_course/webInterFace.png'),
              ),
            ],
          ),
          Positioned(
            top: 60,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3A5160).withOpacity(0.2),
                    offset: const Offset(1.1, 1.1),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: infoHeight,
                      maxHeight:
                          tempHeight > infoHeight ? tempHeight : infoHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 32.0,
                            left: 18,
                            right: 16,
                          ),
                          child: Text(
                            controller.task.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              letterSpacing: 0.27,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Text(
                            controller.task.desc,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                            top: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'complete_condition'.tr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  fontSize: 22,
                                  letterSpacing: 0.27,
                                  color: ThemeProvider.style.normal(),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${controller.completedNumber}/${controller.forms.value.length}',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w200,
                                      fontSize: 22,
                                      letterSpacing: 0.27,
                                      color: Color(0xFF3A5160),
                                    ),
                                  ),
                                  Icon(
                                    Icons.loop,
                                    color: Theme.of(context).iconTheme.color,
                                    // color: ThemeProvider.style.normal(),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: opacity1,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height: 95,
                              child: Obx(
                                () => taskForms((form) {
                                  controller.selectedTask = form;
                                  switch (form.type.index) {
                                    case 0:
                                      body.value = Container();
                                    case 4:
                                      if (form.param.value.isNotEmpty) {
                                        body.value = GridView.count(
                                          crossAxisCount: 3,
                                          shrinkWrap: true,
                                          children:
                                              form.param.value
                                                  .split(",")
                                                  .map(
                                                    (e) => Image.network(
                                                      "${Guard.server}/task/image/$e",
                                                    ),
                                                  )
                                                  .toList(),
                                        );
                                      } else {
                                        body.value = Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                TFile? img =
                                                    await imagePicker();
                                                if (img != null) {
                                                  controller.images.add(img);
                                                  var idx =
                                                      controller.images.length -
                                                      1;
                                                  imageWidgets.value.add(
                                                    Stack(
                                                      children: [
                                                        file2Image(
                                                          img,
                                                          fit: BoxFit.fill,
                                                          width: 200,
                                                          height: 200,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            controller.images
                                                                .removeAt(idx);
                                                            imageWidgets.value
                                                                .removeAt(idx);
                                                            imageWidgets
                                                                .refresh();
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  right: 10,
                                                                  top: 10,
                                                                ),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                color:
                                                                    const Color(
                                                                      0x66000000,
                                                                    ),
                                                              ),
                                                              child: const Icon(
                                                                Icons.close,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  imageWidgets.refresh();
                                                }
                                              },
                                              child: selectImagePicker(),
                                            ),
                                            Obx(
                                              () => GridView.count(
                                                crossAxisCount: 3,
                                                shrinkWrap: true,
                                                children: [
                                                  ...imageWidgets.value,
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    case 2:
                                      body.value = Obx(
                                        () =>
                                            form.param.value.isNotEmpty
                                                ? SizedBox(
                                                  height: 300,
                                                  child: Image.network(
                                                    "${Guard.server}/task/locate/${form.param.value}",
                                                  ),
                                                )
                                                : Container(),
                                      );
                                    case 3:
                                    case 5:
                                      if (form.param.value.isNotEmpty) {
                                        body.value = Text(form.param.value);
                                      } else {
                                        body.value = TextArea(
                                          controller:
                                              controller.textAreaController,
                                        );
                                      }
                                    case 6:
                                      taskHasPerm(
                                            TaskHasPermRequest(
                                              tid: controller.id,
                                            ),
                                          )
                                          .then((res) {
                                            if (res.has) {
                                              if (form.wantCond != null &&
                                                  form.wantCond!.isNotEmpty) {
                                                String key = form.wantCond![0];
                                                controller.qrListen(key);
                                                // post request and updates qrCode
                                                body.value = Column(
                                                  children: [
                                                    Obx(
                                                      () => QrImageView(
                                                        size: 100,
                                                        data:
                                                            controller
                                                                .qrCode
                                                                .value,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            } else {
                                              body.value = GestureDetector(
                                                onTap: () {},
                                                child: const BubbleContainer(
                                                  child: Icon(Icons.crop_free),
                                                ),
                                              );
                                            }
                                          })
                                          .onError((error, stackTrace) {
                                            EasyLoading.showError(
                                              error.toString(),
                                            );
                                          });
                                    default:
                                      body.value = Container();
                                  }
                                }),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: opacity2,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.condDesc,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w200,
                                        fontSize: 14,
                                        letterSpacing: 0.27,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Obx(() => body.value),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: opacity3,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              bottom: 16,
                              right: 16,
                            ),
                            child: bottom(),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 35,
            child: ScaleTransition(
              alignment: Alignment.center,
              scale: CurvedAnimation(
                parent: animationController!,
                curve: Curves.fastOutSlowIn,
              ),
              child: refreshButton(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: title(),
          ),
        ],
      ),
    );
  }

  Widget title() {
    return Row(
      children: [
        SizedBox(
          width: AppBar().preferredSize.height,
          height: AppBar().preferredSize.height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                AppBar().preferredSize.height,
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onTap: () {
                Get.back();
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            controller.task.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 28),
          ),
        ),
      ],
    );
  }

  Widget bottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              border: Border.all(
                color: const Color(0xFF3A5160).withOpacity(0.2),
              ),
            ),
            child: Icon(
              Icons.sort,
              color: ThemeProvider.style.normal(),
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Obx(
          () => LightButton(
            onTap: () {
              if (controller.selectedTask.type == TaskCondType.image) {
                controller.commitOnTap(controller.images);
              } else if (controller.selectedTask.type == TaskCondType.content) {
                controller.commitOnTap(controller.textAreaController.text);
              } else {
                controller.commitOnTap("");
              }
            },
            text: controller.commitText,
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.0,
              color: ThemeProvider.backgroundColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget refreshButton() {
    return GestureDetector(
      onTap: () {},
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        elevation: 10.0,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: Icon(
              Icons.offline_bolt,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget taskForms(ValueChanged<TaskForm> onTap) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: controller.forms.value.length,
      itemBuilder: (ctx, idx) {
        return taskFormContainer(controller.forms.value[idx], idx, (value) {
          for (var j = 0; j < controller.forms.value.length; j++) {
            var form = controller.forms.value[j];
            if (j != idx) {
              form.selected = false;
            } else {
              form.selected = true;
              onTap(form);
            }
            controller.forms.refresh();
          }
        });
      },
    );
  }

  Widget taskFormContainer(TaskForm model, int index, ValueChanged<int> onTap) {
    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: BubbleContainer(
        backgroundColor:
            model.selected
                ? Theme.of(context).primaryColorLight
                : ThemeProvider.contrastColor(
                  context,
                  dark: HexColor.fromInt(0x1c1c1e),
                ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              model.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.27,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Icon(
              model.isCompleted ? Icons.task : Icons.content_paste,
              color: Colors.grey,
            ),
          ],
        ),
      ),
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
  final QuillController controller = () {
    return QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onImagePaste: (imageBytes) async {
            if (kIsWeb) {
              // Dart IO is unsupported on the web.
              return null;
            }
            // Save the image somewhere and return the image URL that will be
            // stored in the Quill Delta JSON (the document).
            final newFileName =
                'image-file-${DateTime.now().toIso8601String()}.png';
            final newPath = path.join(
              io.Directory.systemTemp.path,
              newFileName,
            );
            final file = await io.File(
              newPath,
            ).writeAsBytes(imageBytes, flush: true);
            return file.path;
          },
        ),
      ),
    );
  }();

  final FocusNode editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: controller,
            config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              showClipboardPaste: true,
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: const Icon(Icons.add_alarm_rounded),
                  onPressed: () {
                    controller.document.insert(
                      controller.selection.extentOffset,
                      TimeStampEmbed(DateTime.now().toString()),
                    );
                    controller.updateSelection(
                      TextSelection.collapsed(
                        offset: controller.selection.extentOffset + 1,
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
              controller: controller,
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
