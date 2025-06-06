// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/component/button/like_button.dart';
import 'package:my_todo/component/container/empty_container.dart';
import 'package:my_todo/component/icon.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/component/input.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:get/get.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/image.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/add/add_post_page.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:my_todo/view/post/component/profile.dart';
import 'package:my_todo/view/post/detail/post_detail_controller.dart';
import 'package:my_todo/view/post/detail/widgets/comment_card.dart';
import 'package:my_todo/view/post/detail/widgets/reply_card.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  PostDetailController controller = Get.find<PostDetailController>();

  int replaySubID = 0;
  Widget todoDivider(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return const Divider();
    }
    return Divider(color: Colors.grey.withOpacity(0.5));
  }

  late TodoInputController todoInputController;
  @override
  void initState() {
    super.initState();
    todoInputController = TodoInputController(
      TextEditingController(),
      TextEditingController(),
    );
    // Future.delayed(Duration.zero, controller.fetchAll);
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<EmojiPickerState>();
    todoInputController.defaultConfig(context);
    return Scaffold(
      appBar: todoAppBar(
        context,
        elevation: 0,
        leading: todoLeadingIconButton(
          context,
          onPressed: Get.back,
          icon: Icons.arrow_back_ios,
        ),
        title: Obx(() => Text(controller.data.value.title)),
        actions: [
          Row(
            children: [
              Obx(
                () => favoriteButton(
                  context,
                  selected: controller.isFavorite.value,
                  onChange: (v) {
                    postLikeRequest(postId: controller.data.value.id).then((
                      ok,
                    ) {
                      if (ok != null) {
                        controller.updateFavorite(!controller.isFavorite.value);
                      }
                    });
                  },
                ),
              ),
              Obx(() => Text("${controller.likeCount.value}")),
            ],
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              TodoShare.shareUri(context, Uri.parse(Get.currentRoute));
            },
            icon: const Icon(Icons.open_in_new),
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: ThemeProvider.contrastColor(
                          context,
                          light: HexColor.fromInt(0xceced2),
                          dark: Colors.grey.withOpacity(0.8),
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TodoInput(
                      showChild: controller.showReply,
                      controller: todoInputController,
                      onTap: (v) {
                        if (v.isEmpty) {
                          return;
                        }
                        controller.postMessage(v).then((value) {
                          setState(() {});
                        });
                        // if (controller.isCommentReply()) {
                        //   if (replaySubID == 0) {
                        //     controller
                        //         .comments[controller.selectedComment]?.replies
                        //         .add(PostComment(
                        //             content: [v],
                        //             id: "",
                        //             images: [],
                        //             username: "",
                        //             createdAt: DateTime.now(),
                        //             replies: []));
                        //   }
                        //   replaySubID = 0;
                        //   controller.freeCommentReply();
                      },
                      child: replyBar(),
                    ),
                  ),
                ),
                TodoInputView(
                  controller: todoInputController,
                  state: key,
                  maxWidth: constraints.maxWidth,
                ),
              ],
            );
          },
        ),
      ),
      body: refreshContainer(
        context: context,
        onLoad: () {},
        onRefresh: () {
          controller.fetchComments().then((_) {
            setState(() {});
          });
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _postHeader(),
                _postBody(),
                _postFoot(),
                // ...controller.model.imageUri
                //     .map((e) => Image.network(e))
                //     .toList(),
                // ImageDisplay(
                //   images: imgList,
                // ),
                const SizedBox(height: 5),
                todoDivider(context),
                _postReply(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _postHeader() {
    return Row(
      children: [
        Obx(
          () =>
              controller.data.value.uid != 0
                  ? userProfile(
                    isMale: controller.data.value.isMale,
                    id: controller.data.value.uid,
                  )
                  : const SizedBox.shrink(),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.data.value.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Obx(() => Text(controller.data.value.about)),
              // RawChip(
              //   backgroundColor: Theme.of(context).primaryColorLight,
              //   materialTapTargetSize: MaterialTapTargetSize.padded,
              //   avatar: Icon(
              //     Icons.location_on,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              //   label: Text(
              //     "unknown".tr,
              //     style: TextStyle(
              //       color: Theme.of(context).colorScheme.primary,
              //       fontSize: 12,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _postBody() {
    return QuillEditor(
      focusNode: FocusNode(),
      scrollController: ScrollController(),
      controller: controller.quillController,
      config: QuillEditorConfig(
        scrollable: false,
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
    );
  }

  Widget _postFoot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
            SizedBox(width: 5),
            Obx(
              () => Text(
                "浏览${controller.data.value.visitCount}次",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
        Obx(
          () => Text(
            DateFormat(
              "yyyy-MM-dd HH:mm:ss",
            ).format(controller.data.value.createdAt),
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _postReply() {
    return EmptyContainer(
      icon: Icons.comment,
      desc: "try_send_comment".tr,
      what: "",
      render: true,
      child: Obx(
        () => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.comments.value.length,
          itemBuilder: (BuildContext context, int index) {
            int key = controller.comments.value.keys.elementAt(index);
            PostComment comment = controller.comments.value[key]!;
            return CommentCard(
              postId: controller.id,
              userId: comment.userId,
              text: comment.text,
              layer: index + 1,
              userProfile: TodoImage.userProfile(comment.userId),
              username: comment.username,
              createdAt: comment.createdAt,
              more: () {
                showCupertinoModalPopup(
                  context: context,
                  builder:
                      (context) => CupertinoActionSheet(
                        message: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            dialogAction(
                              icon: Icons.reply,
                              text: "reply".tr,
                              onTap: () {
                                Get.back();
                                controller.setCommentReply(comment.id);
                              },
                            ),
                            const Divider(),
                            dialogAction(icon: Icons.copy, text: "copy".tr),
                            const Divider(),
                            dialogAction(
                              icon: Icons.warning,
                              text: "report".tr,
                            ),
                            if (comment.userId ==
                                controller.data.value.uid) ...[
                              const Divider(),
                              dialogAction(
                                icon: Icons.delete,
                                text: "delete".tr,
                              ),
                            ],
                          ],
                        ),
                      ),
                );
              },
              model: comment,

              chat: () async {
                await controller.commentReplyCard(comment.id);
                showSheetBottom(
                  context,
                  title: "comment".tr,
                  childPadding: EdgeInsets.zero,
                  child: Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: CommentCard(
                            postId: controller.id,
                            userId: comment.userId,
                            text: comment.text,
                            layer: index + 1,
                            userProfile: TodoImage.userProfile(comment.userId),
                            username: comment.username,
                            createdAt: comment.createdAt,
                            model: comment,
                            chat: () {
                              Get.back();
                              controller.setCommentReply(comment.id);
                            },
                            more: () {},
                          ),
                        ),
                        Container(
                          height: 10,
                          color: ThemeProvider.contrastColor(
                            context,
                            light: CupertinoColors.lightBackgroundGray,
                            dark: CupertinoColors.darkBackgroundGray,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, idx) {
                              PostComment reply =
                                  controller.replies[comment.id]![idx];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: ReplyCard(
                                  model: reply,
                                  postId: controller.id,
                                  userId: reply.userId,
                                  text: reply.text,
                                  isSelf:
                                      controller.data.value.uid == reply.userId,
                                  senderBy: reply.username,
                                  userProfile: TodoImage.userProfile(
                                    reply.userId,
                                  ),
                                  replyBy: reply.replyName,
                                  createdAt: reply.createdAt,
                                  layer: idx + 1,
                                  replyCallback: () {
                                    controller.setCommentReply(reply.id);
                                    Get.back();
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (ctx, idx) {
                              return todoDivider(context);
                            },
                            itemCount:
                                controller.replies.isNotEmpty
                                    ? controller.replies[comment.id]!.length
                                    : 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return todoDivider(context);
          },
        ),
      ),
    );
  }

  Widget replyBar() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeProvider.contrastColor(
          context,
          light: Colors.grey.withOpacity(0.2),
          dark: Colors.black.withOpacity(0.2),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text("${"reply".tr} ${controller.selectedComment}:"),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                controller.clearCommentReply();
              });
            },
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class ImageDisplay extends StatefulWidget {
  final List<String> images;
  const ImageDisplay({super.key, required this.images});

  @override
  State<ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    if (widget.images.length <= 9) {
      return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3, // 每行显示的图片数量
        crossAxisSpacing: 8.0, // 图片之间的横向间距
        mainAxisSpacing: 8.0, // 图片之间的纵向间距
        children: List.generate(
          widget.images.length,
          (index) => ImageView.network(widget.images[index], fit: BoxFit.cover),
        ),
      );
    }
    return ImageSliderDisplay(images: widget.images);
  }
}

class ImageSliderDisplay extends StatefulWidget {
  final List<String> images;
  const ImageSliderDisplay({super.key, required this.images});

  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<ImageSliderDisplay> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  late final List<Widget> imageSliders;
  @override
  void initState() {
    super.initState();
    imageSliders =
        widget.images
            .map(
              (item) => Container(
                margin: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: [
                      ImageView.network(item, fit: BoxFit.cover, width: 1000.0),
                      // Positioned(
                      //   bottom: 0.0,
                      //   left: 0.0,
                      //   right: 0.0,
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //       gradient: LinearGradient(
                      //         colors: [
                      //           Color.fromARGB(200, 0, 0, 0),
                      //           Color.fromARGB(0, 0, 0, 0)
                      //         ],
                      //         begin: Alignment.bottomCenter,
                      //         end: Alignment.topCenter,
                      //       ),
                      //     ),
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: 10.0, horizontal: 20.0),
                      //     child: Text(
                      //       'No. ${imgList.indexOf(item)} image',
                      //       style: const TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 20.0,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            )
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: imageSliders,
          carouselController: _controller,
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

final imgList = Mock.images(len: 10);

class ImageSliderDemo extends StatelessWidget {
  const ImageSliderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(disableCenter: true),
      items:
          imgList
              .map(
                (item) => Center(
                  child: ImageView.network(
                    item,
                    fit: BoxFit.cover,
                    width: 1000,
                  ),
                ),
              )
              .toList(),
    );
  }
}
