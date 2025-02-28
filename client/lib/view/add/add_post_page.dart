import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:my_todo/view/add/add_controller.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  AddController addController = Get.find<AddController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: TextField(
            controller: addController.post.textEditingController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              hintText: 'Enter your title here...',
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
            ),
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.output),
              tooltip: 'Print Delta JSON to log',
              onPressed: () async {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(
                //     content: Text(
                //       'The JSON Delta has been printed to the console.',
                //     ),
                //   ),
                // );
                // HTTP.post("/post/new", data: {
                //   "text": jsonEncode(_controller.document.toDelta().toJson())
                // });
                debugPrint(addController.post.textEditingController.text);
                debugPrint(
                  jsonEncode(
                    addController.post.controller.document.toDelta().toJson(),
                  ),
                );
                var delta = addController.post.controller.document.toDelta();
                List<dio.MultipartFile> files = [];
                for (var op in delta.toList()) {
                  if (op.isInsert) {
                    if (op.data is String) {
                      print("文本: ${op.data}");
                    } else if (op.data is Map) {
                      Map<String, dynamic> data =
                          op.data as Map<String, dynamic>;
                      if (data.containsKey("image")) {
                        String path = data["image"];
                        // final filename = uuid.v1();
                        dio.MultipartFile? file = await pathToMultipartFile(
                          path,
                          "image",
                        );
                        if (file != null) {
                          files.add(file);
                        }
                        // data["image"] = filename;
                      } else if (data.containsKey("video")) {
                        String path = data["video"];
                        dio.MultipartFile? file = await pathToMultipartFile(
                          path,
                          "video",
                        );
                        if (file != null) {
                          files.add(file);
                        }
                      }
                    }
                  }
                }
                print(files);
              },
            ),
          ],
        ),
      ),
      // appBar: AppBar(
      //   title: Text('Flutter Quill Example'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.output),
      //       tooltip: 'Print Delta JSON to log',
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //             content:
      //                 Text('The JSON Delta has been printed to the console.')));
      //         HTTP.post("/post/new", data: {
      //           "text": jsonEncode(_controller.document.toDelta().toJson())
      //         });
      //       },
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            QuillSimpleToolbar(
              controller: addController.post.controller,
              config: QuillSimpleToolbarConfig(
                embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                showClipboardPaste: true,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.add_alarm_rounded),
                    onPressed: () {
                      addController.post.controller.document.insert(
                        addController.post.controller.selection.extentOffset,
                        TimeStampEmbed(DateTime.now().toString()),
                      );

                      addController.post.controller.updateSelection(
                        TextSelection.collapsed(
                          offset:
                              addController
                                  .post
                                  .controller
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
                        addController.post.editorFocusNode.requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: QuillEditor(
                focusNode: addController.post.editorFocusNode,
                scrollController: addController.post.editorScrollController,
                controller: addController.post.controller,
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
      ),
    );
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(String value) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}

Future<dio.MultipartFile?> pathToMultipartFile(String path, String type) async {
  if (path.startsWith("/data")) {
    // 直接读取本地文件
    String filePath = Uri.parse(path).toFilePath();
    return await dio.MultipartFile.fromFile(
      filePath,
      filename: filePath.split('/').last,
    );
  }
  return null;
}
