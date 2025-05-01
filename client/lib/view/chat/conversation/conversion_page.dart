// Copyright 2025 The mytodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' as getx;
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/config.dart';
import 'package:my_todo/data.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/theme.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/view/chat/conversation/conversion_controller.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class ConversionPage extends StatefulWidget {
  const ConversionPage({super.key});

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  AppTheme theme = LightTheme();

  ConversionController controller = getx.Get.find<ConversionController>();

  void _showHideTypingIndicator() {
    controller.chatController.setTypingIndicator =
        !controller.chatController.showTypingIndicator;
  }

  void receiveMessage() async {
    controller.chatController.addMessage(
      Message(
        id: DateTime.now().toString(),
        message: 'I will schedule the meeting.',
        createdAt: DateTime.now(),
        sentBy: '2',
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    controller.chatController.addReplySuggestions([
      const SuggestionItemData(text: 'Thanks.'),
      const SuggestionItemData(text: 'Thank you very much.'),
      const SuggestionItemData(text: 'Great.'),
    ]);
  }

  MessageType convert(int i) {
    switch (i) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.voice;
      case 3:
        return MessageType.custom;
    }
    return MessageType.text;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () async {
      List<dynamic> data = await chatGet(
        id: controller.chatsnapshot.id,
        page: 1,
        pageSize: 10,
        isTopic: controller.chatsnapshot.isTopic,
      );
      for (var v in data) {
        List<String> reactions = [];
        List<String> reactedUserIds = [];
        if (v['reaction'] != null) {
          for (var reaction in v['reaction']) {
            reactions.add(reaction['reaction']);
            reactedUserIds.add(reaction['reactedUserId'].toString());
          }
        }

        switch (v["message_type"]) {
          case 0:
            Message message;

            if (v["reply_id"] != 0) {
              Map<String, dynamic> reply = v["reply_message"];
              String replyMessage = reply["message"];
              MessageType replyType = convert(reply["message_type"]);
              if (replyType == MessageType.image) {
                if (controller.chatsnapshot.isTopic) {
                  replyMessage =
                      "${TodoConfig.baseUri}/chat/topic/image/$replyMessage";
                } else {
                  replyMessage =
                      "${TodoConfig.baseUri}/chat/friend/image/$replyMessage";
                }
              }
              message = Message(
                id: v["id"].toString(),
                messageType: MessageType.text,
                message: v["message"],
                createdAt: DateTime.parse(v["createdAt"]),
                sentBy: v["sentBy"].toString(),
                replyMessage: ReplyMessage(
                  messageId: reply["messageId"].toString(),
                  message: replyMessage,
                  replyBy: reply["replyBy"].toString(),
                  replyTo: reply["replyTo"].toString(),
                  messageType: replyType,
                  // voiceMessageDuration: Duration(
                  //   seconds: reply["voice_message_duration"] as int,
                  // ),
                ),
                reaction: Reaction(
                  reactions: reactions,
                  reactedUserIds: reactedUserIds,
                ),
              );
            } else {
              message = Message(
                id: v["id"].toString(),
                messageType: MessageType.text,
                message: v["message"],
                createdAt: DateTime.parse(v["createdAt"]),
                sentBy: v["sentBy"].toString(),
                reaction: Reaction(
                  reactions: reactions,
                  reactedUserIds: reactedUserIds,
                ),
              );
            }
            controller.chatController.addMessage(message);
          case 1:
            controller.chatController.addMessage(
              Message(
                id: v["id"].toString(),
                messageType: MessageType.image,
                message:
                    controller.chatsnapshot.isTopic
                        ? '${TodoConfig.baseUri}/chat/topic/image/${v["message"]}'
                        : '${TodoConfig.baseUri}/chat/friend/image/${v["message"]}',
                createdAt: DateTime.parse(v["createdAt"]),
                sentBy: v["sentBy"].toString(),
                reaction: Reaction(
                  reactions: reactions,
                  reactedUserIds: reactedUserIds,
                ),
              ),
            );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
        chatController: controller.chatController,
        onSendTap: _onSendTap,
        featureActiveConfig: const FeatureActiveConfig(
          lastSeenAgoBuilderVisibility: true,
          receiptsBuilderVisibility: true,
          enableScrollToBottomButton: true,
        ),
        scrollToBottomButtonConfig: ScrollToBottomButtonConfig(
          backgroundColor: Theme.of(context).primaryColorLight,
          border: Border.all(
            color: ThemeProvider.contrastColor(
              context,
              light: Colors.grey,
              dark: Colors.transparent,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black,
            weight: 10,
            size: 30,
          ),
        ),
        chatViewState: ChatViewState.hasMessages,
        chatViewStateConfig: ChatViewStateConfiguration(
          loadingWidgetConfig: ChatViewStateWidgetConfiguration(
            loadingIndicatorColor: Theme.of(context).primaryColor,
          ),
          onReloadButtonTap: () {},
        ),
        typeIndicatorConfig: TypeIndicatorConfiguration(
          flashingCircleBrightColor: Theme.of(context).primaryColorLight,
          flashingCircleDarkColor: Theme.of(context).primaryColorDark,
        ),
        appBar: ChatViewAppBar(
          elevation: 0,
          backGroundColor: Theme.of(context).colorScheme.primary,
          leading: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: ThemeProvider.contrastColor(
                    context,
                    light: Colors.black,
                    dark: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 5),
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).primaryColorLight,
                child:
                    controller.chatsnapshot.isTopic
                        ? CircleAvatar(
                          radius: 25,
                          child: SvgPicture.asset(controller.chatsnapshot.icon),
                        )
                        : CircleAvatar(
                          backgroundImage: TodoImage.userProfile(
                            controller.chatsnapshot.id,
                          ),
                          radius: 25,
                        ),
              ),
              SizedBox(width: 10),
            ],
          ),
          backArrowColor: ThemeProvider.contrastColor(
            context,
            light: Colors.black,
            dark: Theme.of(context).primaryColor,
          ),
          chatTitle: controller.chatsnapshot.name,
          chatTitleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.25,
          ),
          userStatus: () {
            if (!controller.chatsnapshot.isTopic) {
              if (controller.chatsnapshot.isOnline) {
                return "online".tr;
              } else {
                return "offline".tr;
              }
            }
            // TODO: xx person online
            return "${Mock.number()} ${"online".tr}";
          }(),
          userStatusTextStyle: const TextStyle(color: Colors.grey),
          actions: [
            IconButton(
              tooltip: 'Toggle TypingIndicator',
              onPressed: _showHideTypingIndicator,
              icon: Icon(
                Icons.keyboard,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            IconButton(
              tooltip: 'Simulate Message receive',
              onPressed: receiveMessage,
              icon: Icon(
                Icons.supervised_user_circle,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          messageTimeIconColor: ThemeProvider.contrastColor(
            context,
            light: Colors.black,
            dark: Colors.white,
          ),
          messageTimeTextStyle: TextStyle(
            color: ThemeProvider.contrastColor(
              context,
              light: Colors.black,
              dark: Colors.white,
            ),
          ),
          defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
            textStyle: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
              fontSize: 17,
            ),
          ),
          backgroundColor: ThemeProvider.contrastColor(
            context,
            light: CupertinoColors.lightBackgroundGray,
            dark: Theme.of(context).colorScheme.primary,
          ),
        ),
        sendMessageConfig: SendMessageConfiguration(
          imagePickerIconsConfig: ImagePickerIconsConfiguration(
            cameraIconColor: ThemeProvider.contrastColor(
              context,
              light: Colors.black,
              dark: Theme.of(context).primaryColor,
            ),
            galleryIconColor: ThemeProvider.contrastColor(
              context,
              light: Colors.black,
              dark: Theme.of(context).primaryColor,
            ),
          ),
          replyMessageColor: Colors.black,
          defaultSendButtonColor: Theme.of(context).primaryColor,
          replyDialogColor: Theme.of(context).primaryColorLight,
          replyTitleColor: Theme.of(context).primaryColor,
          textFieldBackgroundColor: ThemeProvider.contrastColor(
            context,
            light: Colors.grey.shade100,
            dark: CupertinoColors.darkBackgroundGray,
          ),
          closeIconColor: Colors.black,
          textFieldConfig: TextFieldConfiguration(
            onMessageTyping: (status) {
              /// Do with status
              debugPrint(status.toString());
            },
            compositionThresholdTime: const Duration(seconds: 1),
            textStyle: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
          ),
          micIconColor: Colors.black,
          voiceRecordingConfiguration: VoiceRecordingConfiguration(
            backgroundColor: ThemeProvider.contrastColor(
              context,
              light: Colors.white,
              dark: Theme.of(context).primaryColorLight,
            ),
            recorderIconColor: ThemeProvider.contrastColor(
              context,
              light: Colors.black,
              dark: Theme.of(context).primaryColor,
            ),
            waveStyle: WaveStyle(
              showMiddleLine: false,
              waveColor: Colors.black,
              extendWaveform: true,
            ),
          ),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          outgoingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              backgroundColor: ThemeProvider.contrastColor(
                context,
                light: Color(0xffFCD8DC),
                dark: Color(0xff272336),
              ),
              bodyStyle: TextStyle(
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.grey,
                  dark: Colors.white,
                ),
              ),
              titleStyle: TextStyle(
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black,
                  dark: Colors.white,
                ),
              ),
            ),
            receiptsWidgetConfig: const ReceiptsWidgetConfig(
              showReceiptsIn: ShowReceiptsIn.all,
            ),
            color: Theme.of(context).primaryColor,
          ),
          inComingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              linkStyle: TextStyle(
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black,
                  dark: Colors.white,
                ),
                decoration: TextDecoration.underline,
              ),
              backgroundColor: theme.linkPreviewIncomingChatColor,
              bodyStyle: theme.incomingChatLinkBodyStyle,
              titleStyle: theme.incomingChatLinkTitleStyle,
            ),
            textStyle: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
            onMessageRead: (message) {
              /// send your message reciepts to the other client
              debugPrint('Message Read');
            },
            senderNameTextStyle: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
            color: ThemeProvider.contrastColor(
              context,
              light: Colors.white,
              dark: CupertinoColors.darkBackgroundGray,
            ),
          ),
        ),
        replyPopupConfig: ReplyPopupConfiguration(
          backgroundColor: Theme.of(context).colorScheme.primary,
          buttonTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          topBorderColor: Theme.of(context).colorScheme.onPrimary,
        ),
        reactionPopupConfig: ReactionPopupConfiguration(
          shadow: BoxShadow(
            color: ThemeProvider.contrastColor(
              context,
              light: Colors.grey.shade400,
              dark: Colors.black54,
            ),
            blurRadius: 20,
          ),
          backgroundColor: Theme.of(context).primaryColorLight,
          userReactionCallback: (message, emoji) async {
            if (controller.chatsnapshot.isTopic) {
              await chatTopicReaction(
                messageId: int.parse(message.id),
                emoji: emoji,
              );
            } else {
              await chatFriendReaction(
                messageId: int.parse(message.id),
                emoji: emoji,
              );
            }
          },
        ),
        messageConfig: MessageConfiguration(
          customMessageBuilder: (msg) {
            Map _custom = jsonDecode(msg.message);
            final _controller = VideoPlayerController.networkUrl(
              Uri.parse(_custom["data"]),
            )..initialize();
            controller.videoplayers.putIfAbsent(msg.id, () {
              return _controller;
            });

            return BubbleChat(
              isSender: msg.sentBy == controller.chatController.currentUser.id,
              child: InkWell(
                child: videoSection(_controller),
                onTap: () {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                },
              ),
            );
          },
          customMessageReplyViewBuilder: (msg) {
            Map _custom = jsonDecode(msg.message);
            return Text(_custom["data"]);
          },
          messageReactionConfig: MessageReactionConfiguration(
            backgroundColor: ThemeProvider.contrastColor(
              context,
              light: Color(0xFFEEEEEE),
              dark: Colors.black,
            ),
            borderColor: ThemeProvider.contrastColor(
              context,
              light: Color(0xFFEEEEEE),
              dark: Colors.grey.shade100,
            ),
            reactedUserCountTextStyle: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
            reactionCountTextStyle: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
            reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
              backgroundColor: Theme.of(context).colorScheme.primary,
              reactedUserTextStyle: TextStyle(
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.black,
                  dark: Colors.white,
                ),
              ),
              reactionWidgetDecoration: BoxDecoration(
                color: ThemeProvider.contrastColor(
                  context,
                  light: Colors.white,
                  dark: CupertinoColors.darkBackgroundGray,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeProvider.contrastColor(
                      context,
                      light: Colors.grey.shade200,
                      dark: Colors.black12,
                    ),
                    offset: const Offset(0, 20),
                    blurRadius: 40,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          imageMessageConfig: ImageMessageConfiguration(
            onTap: (msg) {
              RouterProvider.toPhoto(type: PhotoType.img, url: msg.message);
            },
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            shareIconConfig: ShareIconConfiguration(
              defaultIconBackgroundColor: const Color(0xFFE0E0E0),
              defaultIconColor: Colors.black,
            ),
          ),
        ),
        profileCircleConfig: ProfileCircleConfiguration(
          profileImageUrl: Data.profileImage,
          onAvatarTap: (user) {
            RouterProvider.toUserProfile(int.parse(user.id));
          },
        ),
        repliedMessageConfig: RepliedMessageConfiguration(
          backgroundColor: Theme.of(context).primaryColorLight,
          verticalBarColor: Theme.of(context).primaryColor,
          repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
            enableHighlightRepliedMsg: true,
            highlightColor: Theme.of(context).primaryColorLight,
            highlightScale: 1.1,
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.25,
          ),
          replyTitleTextStyle: TextStyle(
            color: ThemeProvider.contrastColor(
              context,
              light: Colors.black,
              dark: Colors.white,
            ),
          ),
        ),
        swipeToReplyConfig: SwipeToReplyConfiguration(
          replyIconColor: Colors.black,
        ),
        replySuggestionsConfig: ReplySuggestionsConfig(
          itemConfig: SuggestionItemConfig(
            decoration: BoxDecoration(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.white,
                dark: CupertinoColors.darkBackgroundGray,
              ),
              // borderRadius: BorderRadius.circular(8),
              // border: Border.all(
              //   color: theme.outgoingChatBubbleColor ?? Colors.white,
              // ),
            ),
            textStyle: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
          ),
          onTap:
              (item) =>
                  _onSendTap(item.text, const ReplyMessage(), MessageType.text),
        ),
      ),
    );
  }

  Widget videoSection(VideoPlayerController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(aspectRatio: 16 / 9, child: VideoPlayer(controller)),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    Message msg = Message(
      id: DateTime.now().toString(),
      createdAt: DateTime.now(),
      message: message,
      sentBy: controller.chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
    );
    controller.chatController.addMessage(msg);
    Future.delayed(const Duration(seconds: 1), () {
      controller.sendMessage(msg.toJson());
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      controller.chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      controller.chatController.initialMessageList.last.setStatus =
          MessageStatus.read;
    });
  }
}

Future<List<int>> _getBlobData(String blobUrl) async {
  // 通过 blob URL 创建一个 HttpRequest
  final request = html.HttpRequest();

  final completer = Completer<List<int>>();

  request
    ..open('GET', blobUrl)
    ..responseType =
        'arraybuffer' // 设置为读取 ArrayBuffer
    ..onLoadEnd.listen((e) {
      if (request.status == 200) {
        final bytes = request.response;
        completer.complete(Uint8List.view(bytes));
      } else {
        completer.completeError('Failed to load blob data');
      }
    })
    ..send();

  return completer.future;
}

Future<void> sendJsonData(Map<String, dynamic> jsonData) async {
  Dio dio = Dio(); // 创建 Dio 实例

  if (kIsWeb) {
    switch (jsonData["message_type"]) {
      case "text":
        Map<String, dynamic> reply = jsonData["reply_message"];
        Response response = await HTTP.post(
          '/chat/topic/new',
          data: {
            "topic_id": 1,
            "message": jsonData["message"],
            "message_type": "text",
            "reply_id": int.parse(reply["id"]),
            "reply_to": int.parse(reply["replyTo"]),
            "reply_by": int.parse(reply["replyBy"]),
            "reply_type": reply["message_type"],
          },
          options: Options(
            headers: {
              'Authorization':
                  'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDA3MTU2OTMsImp0aSI6IjEiLCJpYXQiOjE3NDAxMTA4OTMsImlzcyI6Im9yZy5teV90b2RvIiwic3ViIjoidXNlciB0b2tlbiJ9.jNVj_jTEf4k1eutJ5rXZXXt2pxNeIeJvA8zqnCtRU-U', // 设置 Authorization 头
            },
          ),
        );
        print(response.data);
      case "image":
        final blobData = await _getBlobData(jsonData["message"]);
        try {
          final filename = uuid.v1();
          final formData = FormData.fromMap({
            'file': MultipartFile.fromBytes(
              blobData,
              filename: '$filename.png',
            ),
          });

          Response response = await HTTP.post(
            '/chat/topic/upload',
            data: formData,
            options: Options(
              headers: {
                'Authorization':
                    'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDA3MTU2OTMsImp0aSI6IjEiLCJpYXQiOjE3NDAxMTA4OTMsImlzcyI6Im9yZy5teV90b2RvIiwic3ViIjoidXNlciB0b2tlbiJ9.jNVj_jTEf4k1eutJ5rXZXXt2pxNeIeJvA8zqnCtRU-U', // 设置 Authorization 头
              },
            ),
          );
          await dio.post(
            'http://localhost:8080/chat/topic/new',
            data: {"topic_id": 1, "message": filename, "message_type": "image"},
            options: Options(
              headers: {
                'Authorization':
                    'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDA3MTU2OTMsImp0aSI6IjEiLCJpYXQiOjE3NDAxMTA4OTMsImlzcyI6Im9yZy5teV90b2RvIiwic3ViIjoidXNlciB0b2tlbiJ9.jNVj_jTEf4k1eutJ5rXZXXt2pxNeIeJvA8zqnCtRU-U', // 设置 Authorization 头
              },
            ),
          );
          print('Upload success: ${response.data}');
        } catch (e) {
          print('Error: $e');
        }
        return;
    }
  } else {
    switch (jsonData["message_type"]) {
      case "text":
        Response response = await HTTP.post(
          '/chat/topic/new',
          data: {
            "topic_id": 1,
            "message": jsonData["message"],
            "message_type": "text",
          },
          options: Options(
            headers: {
              'Authorization':
                  'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDA3MTU2OTMsImp0aSI6IjEiLCJpYXQiOjE3NDAxMTA4OTMsImlzcyI6Im9yZy5teV90b2RvIiwic3ViIjoidXNlciB0b2tlbiJ9.jNVj_jTEf4k1eutJ5rXZXXt2pxNeIeJvA8zqnCtRU-U', // 设置 Authorization 头
            },
          ),
        );
        print(response.data);
      case "image":
        try {
          final filePath = jsonData["message"];
          File file = File(filePath);
          if (!await file.exists()) {
            print("文件不存在");
            return;
          }
          MultipartFile fileToSend = await MultipartFile.fromFile(
            filePath,
            filename: 'img.png',
          );

          FormData formData = FormData.fromMap({'file': fileToSend});

          Response response = await HTTP.post(
            '/chat/topic/upload',
            data: formData,
            options: Options(
              headers: {
                'Authorization':
                    'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDA3MTU2OTMsImp0aSI6IjEiLCJpYXQiOjE3NDAxMTA4OTMsImlzcyI6Im9yZy5teV90b2RvIiwic3ViIjoidXNlciB0b2tlbiJ9.jNVj_jTEf4k1eutJ5rXZXXt2pxNeIeJvA8zqnCtRU-U', // 设置 Authorization 头
              },
            ),
          );

          // 处理响应
          if (response.statusCode == 200) {
            print('文件上传成功: ${response.data}');
          } else {
            print('上传失败, 状态码: ${response.statusCode}');
          }
        } catch (e) {
          print('上传时出错: $e');
        }
        return;
    }
  }

  try {
    Response response = await dio.post(
      'http://192.168.0.106:8080/test',
      data: jsonData, // 直接传递 Map，Dio 会自动将其编码为 JSON
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        }, // 确保 Content-Type 是 application/json
      ),
    );

    // 处理响应
    if (response.statusCode == 200) {
      print('Request successful: ${response.data}');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

var uuid = Uuid();

class BubbleChat extends StatelessWidget {
  final Widget child;
  final bool isSender;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  const BubbleChat({
    super.key,
    required this.child,
    required this.isSender,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isSender
                ? Theme.of(context).primaryColor
                : ThemeProvider.contrastColor(
                  context,
                  light: Colors.white,
                  dark: CupertinoColors.darkBackgroundGray,
                )),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
