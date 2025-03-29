// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/view/add/file_area.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  String content = "";
  late List<Widget> images;
  List<String> files = [];
  List<TFile> pickedFiles = [];
  List<TFile> pickedImages = [];

  @override
  void initState() {
    super.initState();
    images = [
      GestureDetector(
          onTap: () async {
            imagePicker().then((file) {
              if (file != null) {
                var idx = images.length;
                pickedImages.add(file);
                images.add(Stack(
                  children: [
                    file2Image(file, fit: BoxFit.fill, width: 200, height: 200),
                    GestureDetector(
                      onTap: () {
                        images.removeAt(idx);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0x66000000)),
                          child: const Icon(Icons.close),
                        ),
                      ),
                    )
                  ],
                ));
                setState(() {});
              }
            });
          },
          child: selectImagePicker(size: 60)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      const SizedBox(height: 15),
      Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.withOpacity(0.05)
            : HexColor.fromInt(0x1c1c1e),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  minLines: 6,
                  maxLines: null,
                  decoration: InputDecoration(
                      hintText: "post_share_thing".tr,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hoverColor: Colors.transparent),
                  onChanged: (v) {
                    content = v;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: [...images],
                ),
                const SizedBox(height: 15),
                _selectFile()
              ],
            )),
      ),
      const SizedBox(height: 10),
      _commitButton()
    ]));
  }

  Widget _selectFile() {
    ThemeData themeData = Theme.of(context);
    return Wrap(
      children: [
        GestureDetector(
          onTap: () async {
            List<TFile> tmpFiles = await filePicker(allowMultiple: true);
            for (var file in tmpFiles) {
              pickedFiles.add(file);
              files.add(file.name);
            }
            setState(() {});
          },
          child: RawChip(
              backgroundColor: themeData.primaryColorLight,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              avatar: Icon(
                Icons.discount,
                size: 20,
                color: themeData.colorScheme.primary,
              ),
              label: Text(
                "选择文件",
                style: TextStyle(
                  color: themeData.colorScheme.primary,
                ),
              )),
        ),
        const SizedBox(width: 5),
        FileArea(files: files),
      ],
    );
  }

  Widget _commitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ShadowButton(
            text: 'save_draft'.tr,
            onTap: () async {
              if (content.isNotEmpty) {
                // await createPost(
                //     CreatePostRequest(Guard.user, content, pickedImages));
                Get.back();
              }
            }),
        ShadowButton(
            text: 'post'.tr,
            onTap: () async {
              if (content.isNotEmpty) {
                // await createPost(
                //     CreatePostRequest(Guard.user, content, pickedImages));
                Get.back();
              }
            })
      ],
    );
  }
}
