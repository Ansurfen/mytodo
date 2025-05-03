// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/task.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/config.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/view/add/add_post_page.dart';
import 'package:my_todo/view/map/locate/locate_page.dart';
import 'package:my_todo/view/task/detail/task_detail_controller.dart';
import 'package:my_todo/view/task/snapshot/task_card.dart';

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
          tabViews.add(TaskClickPage(cond: cond));
        case ConditionType.qr:
          tabViews.add(TaskQRPage());
        case ConditionType.locale:
          tabViews.add(TaskLocalePage(cond: cond));
        case ConditionType.text:
          tabViews.add(TaskTextPage(cond: cond));
        case ConditionType.file:
          tabViews.add(TaskFilePage(cond: cond));
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
        title: Text(controller.model.name),
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
  final ConditionItem cond;
  const TaskClickPage({super.key, required this.cond});

  @override
  State<TaskClickPage> createState() => _TaskClickPage();
}

class _TaskClickPage extends State<TaskClickPage> {
  TaskInfoController controller = Get.find<TaskInfoController>();

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}${"year".tr}${date.month}${"month".tr}${date.day}${"day".tr} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cond.finish) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/click.svg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              'click_finish'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(widget.cond.argument["create_at"]),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.touch_app,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await taskCommitRequest(
                  taskId: controller.model.id,
                  condId: widget.cond.id,
                  argument: {
                    "create_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'click_commit'.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class TaskFilePage extends StatefulWidget {
  final ConditionItem cond;
  const TaskFilePage({super.key, required this.cond});

  @override
  State<TaskFilePage> createState() => _TaskFilePage();
}

class _TaskFilePage extends State<TaskFilePage> {
  TaskInfoController controller = Get.find<TaskInfoController>();
  final RxList<Map<String, dynamic>> files = <Map<String, dynamic>>[].obs;
  final Rx<bool> isUploading = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.cond.finish) {
      files.value = List<Map<String, dynamic>>.from(
        widget.cond.argument["files"] ?? [],
      );
    }
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      final pickedFiles = await filePicker();

      isUploading.value = true;

      final uploadedFile = await taskFileUploadRequest(
        taskId: controller.model.id,
        condId: widget.cond.id,
        file: pickedFiles.first,
      );
      files.add(uploadedFile);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    try {
      await taskFileDownloadRequest(file["filename"]);
      Get.snackbar('success'.tr, 'file_downloaded'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> file) async {
    try {
      await taskFileDeleteRequest(file["filename"]);
      files.remove(file);
      Get.snackbar('success'.tr, 'file_deleted'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cond.finish) {
      return SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'file_finish'.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${"submit_time".tr} ${_formatTime(widget.cond.argument["create_at"])}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _pickAndUploadFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text('upload'.tr),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          _getFileIcon(file["content_type"]),
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(file["original_name"]),
                        subtitle: Text(
                          _formatFileSize(file["size"]),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadFile(file),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteFile(file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'file_upload'.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickAndUploadFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text('upload'.tr),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          _getFileIcon(file["content_type"]),
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(file["original_name"]),
                        subtitle: Text(
                          _formatFileSize(file["size"]),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadFile(file),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteFile(file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  IconData _getFileIcon(String contentType) {
    if (contentType.startsWith('image/')) {
      return Icons.image;
    } else if (contentType.startsWith('video/')) {
      return Icons.video_file;
    } else if (contentType.startsWith('audio/')) {
      return Icons.audio_file;
    } else if (contentType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (contentType.contains('word')) {
      return Icons.description;
    } else if (contentType.contains('excel') ||
        contentType.contains('spreadsheet')) {
      return Icons.table_chart;
    } else if (contentType.contains('powerpoint') ||
        contentType.contains('presentation')) {
      return Icons.slideshow;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}${"year".tr}${date.month}${"month".tr}${date.day}${"day".tr} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class TaskTextPage extends StatefulWidget {
  final ConditionItem cond;
  const TaskTextPage({super.key, required this.cond});

  @override
  State<TaskTextPage> createState() => _TaskTextPage();
}

class _TaskTextPage extends State<TaskTextPage> {
  TaskInfoController controller = Get.find<TaskInfoController>();

  final FocusNode editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();
  final Rx<bool> isEditing = false.obs;

  @override
  void initState() {
    super.initState();
    controller.initTextService();
    if (widget.cond.finish) {
      final doc = widget.cond.argument["doc"] as List;
      controller.quillController!.document = Document.fromJson(doc);
      controller.quillController!.readOnly = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cond.finish) {
      return SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isEditing.value)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'text_finish'.tr,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${"submit_time".tr} ${_formatTime(widget.cond.argument["create_at"])}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  Obx(
                    () =>
                        isEditing.value
                            ? Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    isEditing.value = false;
                                    controller.quillController!.readOnly = true;
                                    final doc =
                                        widget.cond.argument["doc"] as List;
                                    controller
                                        .quillController!
                                        .document = Document.fromJson(doc);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'cancel'.tr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    await taskCommitRequest(
                                      taskId: controller.model.id,
                                      condId: widget.cond.id,
                                      argument: {
                                        "doc":
                                            controller.quillController!.document
                                                .toDelta()
                                                .toList(),
                                        "create_at":
                                            widget.cond.argument["create_at"],
                                      },
                                    );
                                    isEditing.value = false;
                                    controller.quillController!.readOnly = true;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'save'.tr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : ElevatedButton(
                              onPressed: () {
                                isEditing.value = true;
                                controller.quillController!.readOnly = false;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'edit'.tr,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Obx(
                      () =>
                          isEditing.value
                              ? QuillSimpleToolbar(
                                controller: controller.quillController!,
                                config: QuillSimpleToolbarConfig(
                                  embedButtons:
                                      FlutterQuillEmbeds.toolbarButtons(),
                                  showClipboardPaste: true,
                                  customButtons: [
                                    QuillToolbarCustomButtonOptions(
                                      icon: const Icon(Icons.add_alarm_rounded),
                                      onPressed: () {
                                        controller.quillController!.document
                                            .insert(
                                              controller
                                                  .quillController!
                                                  .selection
                                                  .extentOffset,
                                              TimeStampEmbed(
                                                DateTime.now().toString(),
                                              ),
                                            );
                                        controller.quillController!
                                            .updateSelection(
                                              TextSelection.collapsed(
                                                offset:
                                                    controller
                                                        .quillController!
                                                        .selection
                                                        .extentOffset +
                                                    1,
                                              ),
                                              ChangeSource.local,
                                            );
                                      },
                                    ),
                                  ],
                                  buttonOptions:
                                      QuillSimpleToolbarButtonOptions(
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
                              )
                              : Container(),
                    ),
                    Obx(
                      () =>
                          isEditing.value
                              ? QuillEditor(
                                focusNode: editorFocusNode,
                                scrollController: editorScrollController,
                                controller: controller.quillController!,
                                config: QuillEditorConfig(
                                  placeholder: 'text_placeholder'.tr,
                                  padding: const EdgeInsets.all(16),
                                  embedBuilders: [
                                    ...FlutterQuillEmbeds.editorBuilders(
                                      imageEmbedConfig:
                                          QuillEditorImageEmbedConfig(
                                            imageProviderBuilder: (
                                              context,
                                              imageUrl,
                                            ) {
                                              if (imageUrl.startsWith(
                                                'assets/',
                                              )) {
                                                return AssetImage(imageUrl);
                                              }
                                              return null;
                                            },
                                          ),
                                    ),
                                    TimeStampEmbedBuilder(),
                                  ],
                                ),
                              )
                              : QuillEditor(
                                focusNode: editorFocusNode,
                                scrollController: editorScrollController,
                                controller: controller.quillController!,
                                config: QuillEditorConfig(
                                  padding: const EdgeInsets.all(16),
                                  embedBuilders: [
                                    ...FlutterQuillEmbeds.editorBuilders(
                                      imageEmbedConfig:
                                          QuillEditorImageEmbedConfig(
                                            imageProviderBuilder: (
                                              context,
                                              imageUrl,
                                            ) {
                                              if (imageUrl.startsWith(
                                                'assets/',
                                              )) {
                                                return AssetImage(imageUrl);
                                              }
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
              ),
            ),
          ],
        ),
      );
    } else {
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
                              controller
                                  .quillController!
                                  .selection
                                  .extentOffset +
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
                  placeholder: 'text_placeholder'.tr,
                  padding: const EdgeInsets.all(16),
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                        imageProviderBuilder: (context, imageUrl) {
                          if (imageUrl.startsWith('assets/')) {
                            return AssetImage(imageUrl);
                          }
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

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}${"year".tr}${date.month}${"month".tr}${date.day}${"day".tr} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class TaskLocalePage extends StatefulWidget {
  final ConditionItem cond;
  const TaskLocalePage({super.key, required this.cond});

  @override
  State<TaskLocalePage> createState() => _TaskLocalePage();
}

class _TaskLocalePage extends State<TaskLocalePage> {
  TaskInfoController controller = Get.find<TaskInfoController>();

  @override
  Widget build(BuildContext context) {
    if (widget.cond.finish) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '${TodoConfig.baseUri}/task/locate/${widget.cond.argument["image"]}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'locale_finish'.tr,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    } else {
      return MapLocatePage(taskId: controller.model.id, condId: widget.cond.id);
    }
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
