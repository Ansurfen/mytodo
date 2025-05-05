import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/abc/utils.dart';
import 'package:my_todo/api/post.dart';
import 'package:my_todo/component/button/like_button.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/provider.dart';

class CommentCard extends StatefulWidget {
  final String username;
  final DateTime createdAt;
  final ImageProvider userProfile;
  final VoidCallback chat;
  final VoidCallback more;
  final int layer;
  final String text;
  final int userId;
  final PostComment model;
  final int postId;

  const CommentCard({
    super.key,
    required this.userProfile,
    required this.username,
    required this.createdAt,
    required this.chat,
    required this.more,
    required this.layer,
    required this.text,
    required this.userId,
    required this.model,
    required this.postId,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  Rx<bool> isFavorite = false.obs;
  Rx<int> likeCount = 0.obs;
  Rx<int> replyCount = 0.obs;

  @override
  void initState() {
    super.initState();
    likeCount.value = widget.model.likeCount;
    replyCount.value = widget.model.replyCount;
    isFavorite.value = widget.model.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_header(), _body(), Container(height: 10), _foot()],
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                RouterProvider.toUserProfile(widget.model.userId);
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: widget.userProfile,
                backgroundColor: Theme.of(context).primaryColorLight,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(height: 5),
                Text(
                  DateFormat("yyyy-MM-dd HH:mm:ss").format(widget.createdAt),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        Text(
          "#${widget.layer.toString()}",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        // IconButton(
        //   onPressed: () {},
        //   icon: Icon(Icons.more_horiz, color: Colors.grey),
        // ),
      ],
    );
  }

  Widget _body() {
    return Padding(
      padding: EdgeInsets.only(left: 60),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onLongPress: () {
                showSnack(context, "copy success");
              },
              child: Text(widget.text, softWrap: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey),
            Container(width: 5),
            Text(
              "unknown".tr,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Obx(
                  () => favoriteButton(
                    context,
                    selected: isFavorite.value,
                    onChange: (v) {
                      postCommentLikeRequest(
                        postId: widget.postId,
                        commentId: widget.model.id,
                      ).then((ok) {
                        if (ok != null) {
                          isFavorite.value = ok;
                          likeCount.value += ok ? 1 : -1;
                        }
                      });
                    },
                  ),
                ),
                Obx(() => Text("${likeCount.value}")),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: widget.chat,
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: ThemeProvider.contrastColor(
                      context,
                      light: Colors.black,
                      dark: Colors.white,
                    ),
                  ),
                ),
                Obx(() => Text("${replyCount.value}")),
              ],
            ),
            IconButton(
              onPressed: widget.more,
              icon: Icon(
                Icons.more_vert,
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black,
                  dark: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
