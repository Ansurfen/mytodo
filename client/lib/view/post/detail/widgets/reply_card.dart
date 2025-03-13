import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/abc/utils.dart';
import 'package:my_todo/component/button/like_button.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/theme/provider.dart';

class ReplyCard extends StatefulWidget {
  final ImageProvider userProfile;
  final String senderBy;
  final String replyBy;
  final DateTime createdAt;
  final int layer;
  final VoidCallback replyCallback;

  const ReplyCard({
    super.key,
    required this.userProfile,
    required this.senderBy,
    required this.replyBy,
    required this.createdAt,
    required this.layer,
    required this.replyCallback,
  });

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_header(), _body(), Container(height: 10), _foot()],
    );
  }

  Widget _header() {
    List<Widget> title = [
      Text(widget.senderBy, style: TextStyle(fontSize: 12)),
    ];
    if (widget.replyBy.isNotEmpty) {
      title.addAll([
        Container(width: 5),
        Text(
          "reply".tr,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        Container(width: 5),
        Text(widget.replyBy, style: TextStyle(color: Colors.grey)),
      ]);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).primaryColorLight,
              backgroundImage: widget.userProfile,
            ),
            Container(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: title),
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
              child: Text(Mock.text(), softWrap: true),
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
          children: [
            favoriteButton(context, onChange: (v) {}),
            Container(width: 10),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.chat_bubble_outline,
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black,
                  dark: Colors.white,
                ),
              ),
            ),
            Container(width: 10),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black,
                  dark: Colors.white,
                ),
              ),
            ),
            Container(width: 10),
            TextButton(
              onPressed: widget.replyCallback,
              child: Text(
                "reply".tr,
                style: TextStyle(
                  color: ThemeProvider.contrastColor(
                    context,
                    light: Colors.black,
                    dark: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
