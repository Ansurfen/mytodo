// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:my_todo/theme/provider.dart';

class CareTemplateImageWidget extends StatelessWidget {
  final List<String>? imageList;
  final Function? selectedImageCallBack;
  final Size size;
  const CareTemplateImageWidget({
    super.key,
    this.imageList,
    this.selectedImageCallBack,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    int imageCount = imageList!.length;
    return imageCount == 0
        ? Container()
        : SizedBox(
          height: (size.width - 78) / 3,
          // color: Colors.blue,
          child: _buildMoreImageWidget(imageCount),
        );
  }

  Widget _buildMoreImageWidget(int imageCount) {
    return imageCount == 1
        ? _buildImageItemWidget(0)
        : Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildImageItemWidget(0),
            const Padding(padding: EdgeInsets.only(left: 8)),
            imageCount >= 2 ? _buildImageItemWidget(1) : Container(),
            const Padding(padding: EdgeInsets.only(left: 8)),
            imageCount >= 3 ? _buildImageItemWidget(2) : Container(),
          ],
        );
  }

  /// imageItem组件, 当index=2的时候做一个判断，减少组件的创建
  Widget _buildImageItemWidget(int index) {
    return GestureDetector(
      child:
          index == 2
              ? Stack(
                children: [
                  _buildNetWorkImageWidget(index),
                  _buildShadowWidget(index),
                ],
              )
              : _buildNetWorkImageWidget(index),
      onTap: () {
        if (selectedImageCallBack != null) {
          selectedImageCallBack!(index);
        }
      },
    );
  }

  /// 网络图片组件
  Widget _buildNetWorkImageWidget(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: (size.width - 78) / 3,
        height: (size.width - 78) / 3,
        child:
            imageList != null
                ? Image.network(imageList![index], fit: BoxFit.cover)
                : Container(),
      ),
    );
  }

  /// 阴影层
  Widget _buildShadowWidget(int index) {
    return (imageList!.length > 3 && index == 2)
        ? Container(
          width: (size.width - 78) / 3,
          height: (size.width - 78) / 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0x66000000),
          ),
          // WMDecorations.setBoxDecoration(8, color: Color(0x66000000)),
          alignment: Alignment.center,
          child: Text(
            '+${imageList!.length - 3}',
            style: TextStyle(color: ThemeProvider.style.light()),
          ),
        )
        : Container();
  }
}
