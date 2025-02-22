import 'dart:async';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as getX;
import 'package:my_todo/config.dart';
import 'package:my_todo/i18n/i18n.dart';
import 'package:my_todo/net/http.dart';
import 'package:uuid/uuid.dart';
import 'package:chatview/chatview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'data.dart';
import 'models/theme.dart';

void main() {
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    Locale systemLocale = getX.Get.deviceLocale ?? const Locale('en', 'US');
    return getX.GetMaterialApp(
      title: 'my todo',
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      translations: I18N(),
      fallbackLocale: systemLocale,
      theme: ThemeData(
        primaryColor: const Color(0xffEE5366),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xffEE5366),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;
  final _chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    currentUser: ChatUser(
      id: '1',
      name: 'ansurfen',
      profilePhoto: "${TodoConfig.baseUri}/user/profile/1",
    ),
    otherUsers: [
      ChatUser(id: '2', name: 'Simform', profilePhoto: Data.profileImage),
      ChatUser(id: '3', name: 'Jhon', profilePhoto: Data.profileImage),
      ChatUser(id: '4', name: 'Mike', profilePhoto: Data.profileImage),
      ChatUser(id: '5', name: 'Rich', profilePhoto: Data.profileImage),
    ],
  );

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  void receiveMessage() async {
    _chatController.addMessage(
      Message(
        id: DateTime.now().toString(),
        message: 'I will schedule the meeting.',
        createdAt: DateTime.now(),
        sentBy: '2',
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    _chatController.addReplySuggestions([
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
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(microseconds: 10), () async {
      Response response = await HTTP.post(
        '/chat/topic/get',
        data: {"topic_id": 1, "page": 1, "page_size": 20},
        options: Options(
          headers: {
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDA3MTU2OTMsImp0aSI6IjEiLCJpYXQiOjE3NDAxMTA4OTMsImlzcyI6Im9yZy5teV90b2RvIiwic3ViIjoidXNlciB0b2tlbiJ9.jNVj_jTEf4k1eutJ5rXZXXt2pxNeIeJvA8zqnCtRU-U', // 设置 Authorization 头
          },
        ),
      );
      List<dynamic> data = response.data['data'];

      for (var v in data) {
        switch (v["message_type"]) {
          case 0:
            Message message;
            List<String> reactions = [];
            List<String> reactedUserIds = [];

            if (v['reaction'] != null) {
              for (var reaction in v['reaction']) {
                reactions.add(reaction['reaction']);
                reactedUserIds.add(reaction['reactedUserId'].toString());
              }
            }
            if (v["reply_id"] != 0) {
              Map<String, dynamic> reply = v["reply_message"];
              String replyMessage = reply["message"];
              MessageType replyType = convert(reply["message_type"]);
              if (replyType == MessageType.image) {
                replyMessage =
                    "${TodoConfig.baseUri}/chat/topic/image/$replyMessage";
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
            _chatController.addMessage(message);
          case 1:
            _chatController.addMessage(
              Message(
                id: v["id"].toString(),
                messageType: MessageType.image,
                message:
                    '${TodoConfig.baseUri}/chat/topic/image/${v["message"]}',
                createdAt: DateTime.parse(v["createdAt"]),
                sentBy: v["sentBy"].toString(),
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
        chatController: _chatController,
        onSendTap: _onSendTap,
        featureActiveConfig: const FeatureActiveConfig(
          lastSeenAgoBuilderVisibility: true,
          receiptsBuilderVisibility: true,
          enableScrollToBottomButton: true,
        ),
        scrollToBottomButtonConfig: ScrollToBottomButtonConfig(
          backgroundColor: theme.textFieldBackgroundColor,
          border: Border.all(
            color: isDarkTheme ? Colors.transparent : Colors.grey,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.themeIconColor,
            weight: 10,
            size: 30,
          ),
        ),
        chatViewState: ChatViewState.hasMessages,
        chatViewStateConfig: ChatViewStateConfiguration(
          loadingWidgetConfig: ChatViewStateWidgetConfiguration(
            loadingIndicatorColor: theme.outgoingChatBubbleColor,
          ),
          onReloadButtonTap: () {},
        ),
        typeIndicatorConfig: TypeIndicatorConfiguration(
          flashingCircleBrightColor: theme.flashingCircleBrightColor,
          flashingCircleDarkColor: theme.flashingCircleDarkColor,
        ),
        appBar: ChatViewAppBar(
          elevation: theme.elevation,
          backGroundColor: theme.appBarColor,
          profilePicture: Data.profileImage,
          backArrowColor: theme.backArrowColor,
          chatTitle: "Chat view",
          chatTitleTextStyle: TextStyle(
            color: theme.appBarTitleTextStyle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.25,
          ),
          userStatus: "online",
          userStatusTextStyle: const TextStyle(color: Colors.grey),
          actions: [
            IconButton(
              onPressed: _onThemeIconTap,
              icon: Icon(
                isDarkTheme
                    ? Icons.brightness_4_outlined
                    : Icons.dark_mode_outlined,
                color: theme.themeIconColor,
              ),
            ),
            IconButton(
              tooltip: 'Toggle TypingIndicator',
              onPressed: _showHideTypingIndicator,
              icon: Icon(Icons.keyboard, color: theme.themeIconColor),
            ),
            IconButton(
              tooltip: 'Simulate Message receive',
              onPressed: receiveMessage,
              icon: Icon(
                Icons.supervised_user_circle,
                color: theme.themeIconColor,
              ),
            ),
          ],
        ),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          messageTimeIconColor: theme.messageTimeIconColor,
          messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
          defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
            textStyle: TextStyle(color: theme.chatHeaderColor, fontSize: 17),
          ),
          backgroundColor: theme.backgroundColor,
        ),
        sendMessageConfig: SendMessageConfiguration(
          imagePickerIconsConfig: ImagePickerIconsConfiguration(
            cameraIconColor: theme.cameraIconColor,
            galleryIconColor: theme.galleryIconColor,
          ),
          replyMessageColor: theme.replyMessageColor,
          defaultSendButtonColor: theme.sendButtonColor,
          replyDialogColor: theme.replyDialogColor,
          replyTitleColor: theme.replyTitleColor,
          textFieldBackgroundColor: theme.textFieldBackgroundColor,
          closeIconColor: theme.closeIconColor,
          textFieldConfig: TextFieldConfiguration(
            onMessageTyping: (status) {
              /// Do with status
              debugPrint(status.toString());
            },
            compositionThresholdTime: const Duration(seconds: 1),
            textStyle: TextStyle(color: theme.textFieldTextColor),
          ),
          micIconColor: theme.replyMicIconColor,
          voiceRecordingConfiguration: VoiceRecordingConfiguration(
            backgroundColor: theme.waveformBackgroundColor,
            recorderIconColor: theme.recordIconColor,
            waveStyle: WaveStyle(
              showMiddleLine: false,
              waveColor: theme.waveColor ?? Colors.white,
              extendWaveform: true,
            ),
          ),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          outgoingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              backgroundColor: theme.linkPreviewOutgoingChatColor,
              bodyStyle: theme.outgoingChatLinkBodyStyle,
              titleStyle: theme.outgoingChatLinkTitleStyle,
            ),
            receiptsWidgetConfig: const ReceiptsWidgetConfig(
              showReceiptsIn: ShowReceiptsIn.all,
            ),
            color: theme.outgoingChatBubbleColor,
          ),
          inComingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              linkStyle: TextStyle(
                color: theme.inComingChatBubbleTextColor,
                decoration: TextDecoration.underline,
              ),
              backgroundColor: theme.linkPreviewIncomingChatColor,
              bodyStyle: theme.incomingChatLinkBodyStyle,
              titleStyle: theme.incomingChatLinkTitleStyle,
            ),
            textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
            onMessageRead: (message) {
              /// send your message reciepts to the other client
              debugPrint('Message Read');
            },
            senderNameTextStyle: TextStyle(
              color: theme.inComingChatBubbleTextColor,
            ),
            color: theme.inComingChatBubbleColor,
          ),
        ),
        replyPopupConfig: ReplyPopupConfiguration(
          backgroundColor: theme.replyPopupColor,
          buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
          topBorderColor: theme.replyPopupTopBorderColor,
        ),
        reactionPopupConfig: ReactionPopupConfiguration(
          shadow: BoxShadow(
            color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
            blurRadius: 20,
          ),
          backgroundColor: theme.reactionPopupColor,
          userReactionCallback: (message, emoji) async {
            Response response = await HTTP.post(
              "/chat/topic/reaction",
              data: {"message_id": int.parse(message.id), "emoji": emoji},
              options: Options(
                headers: {
                  'Authorization':
                      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDA3MTU2OTMsImp0aSI6IjEiLCJpYXQiOjE3NDAxMTA4OTMsImlzcyI6Im9yZy5teV90b2RvIiwic3ViIjoidXNlciB0b2tlbiJ9.jNVj_jTEf4k1eutJ5rXZXXt2pxNeIeJvA8zqnCtRU-U', // 设置 Authorization 头
                },
              ),
            );
            print(response.data);
          },
        ),
        messageConfig: MessageConfiguration(
          messageReactionConfig: MessageReactionConfiguration(
            backgroundColor: theme.messageReactionBackGroundColor,
            borderColor: theme.messageReactionBackGroundColor,
            reactedUserCountTextStyle: TextStyle(
              color: theme.inComingChatBubbleTextColor,
            ),
            reactionCountTextStyle: TextStyle(
              color: theme.inComingChatBubbleTextColor,
            ),
            reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
              backgroundColor: theme.backgroundColor,
              reactedUserTextStyle: TextStyle(
                color: theme.inComingChatBubbleTextColor,
              ),
              reactionWidgetDecoration: BoxDecoration(
                color: theme.inComingChatBubbleColor,
                boxShadow: [
                  BoxShadow(
                    color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                    offset: const Offset(0, 20),
                    blurRadius: 40,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          imageMessageConfig: ImageMessageConfiguration(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            shareIconConfig: ShareIconConfiguration(
              defaultIconBackgroundColor: theme.shareIconBackgroundColor,
              defaultIconColor: theme.shareIconColor,
            ),
          ),
        ),
        profileCircleConfig: const ProfileCircleConfiguration(
          profileImageUrl: Data.profileImage,
        ),
        repliedMessageConfig: RepliedMessageConfiguration(
          backgroundColor: theme.repliedMessageColor,
          verticalBarColor: theme.verticalBarColor,
          repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
            enableHighlightRepliedMsg: true,
            highlightColor: Colors.pinkAccent.shade100,
            highlightScale: 1.1,
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.25,
          ),
          replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
        ),
        swipeToReplyConfig: SwipeToReplyConfiguration(
          replyIconColor: theme.swipeToReplyIconColor,
        ),
        replySuggestionsConfig: ReplySuggestionsConfig(
          itemConfig: SuggestionItemConfig(
            decoration: BoxDecoration(
              color: theme.textFieldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.outgoingChatBubbleColor ?? Colors.white,
              ),
            ),
            textStyle: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          onTap:
              (item) =>
                  _onSendTap(item.text, const ReplyMessage(), MessageType.text),
        ),
      ),
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
      sentBy: _chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
    );
    _chatController.addMessage(msg);
    Future.delayed(const Duration(seconds: 1), () {
      sendJsonData(msg.toJson());
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
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
  print(jsonData);
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
