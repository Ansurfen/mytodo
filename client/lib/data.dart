import 'dart:convert';

import 'package:chatview/chatview.dart';
import 'package:my_todo/mock/provider.dart';

class Data {
  static const profileImage =
      "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png";
  static final messageList = [
    Message(
      id: '1',
      message: "Hi!",
      createdAt: DateTime.now(),
      sentBy: '1', // userId of who sends the message
      status: MessageStatus.read,
    ),
    Message(
      id: '2',
      message: "Hi!",
      createdAt: DateTime.now(),
      sentBy: '2',
      status: MessageStatus.read,
    ),
    Message(
      id: '3',
      message: "We can meet?I am free",
      createdAt: DateTime.now(),
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '4',
      message: "Can you write the time and place of the meeting?",
      createdAt: DateTime.now(),
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '5',
      message: "That's fine",
      createdAt: DateTime.now(),
      sentBy: '2',
      reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['1']),
      status: MessageStatus.read,
    ),
    Message(
      id: '6',
      message: "When to go ?",
      createdAt: DateTime.now(),
      sentBy: '3',
      status: MessageStatus.read,
    ),
    Message(
      id: '7',
      message: "I guess Simform will reply",
      createdAt: DateTime.now(),
      sentBy: '4',
      status: MessageStatus.read,
    ),
    Message(
      id: '8',
      message: "https://bit.ly/3JHS2Wl",
      createdAt: DateTime.now(),
      sentBy: '2',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{1F44D}', '\u{1F44D}'],
        reactedUserIds: ['2', '3', '4'],
      ),
      status: MessageStatus.read,
      replyMessage: const ReplyMessage(
        message: "Can you write the time and place of the meeting?",
        replyTo: '1',
        replyBy: '2',
        messageId: '4',
      ),
    ),
    Message(
      id: '9',
      message: "Done",
      createdAt: DateTime.now(),
      sentBy: '1',
      status: MessageStatus.read,
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{2764}', '\u{2764}'],
        reactedUserIds: ['2', '3', '4'],
      ),
    ),
    Message(
      id: '10',
      message: "Thank you!!",
      status: MessageStatus.read,
      createdAt: DateTime.now(),
      sentBy: '1',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{2764}', '\u{2764}', '\u{2764}'],
        reactedUserIds: ['2', '4', '3', '1'],
      ),
    ),
    Message(
      id: '11',
      message: "https://miro.medium.com/max/1000/0*s7of7kWnf9fDg4XM.jpeg",
      createdAt: DateTime.now(),
      messageType: MessageType.image,
      sentBy: '1',
      reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['2']),
      status: MessageStatus.read,
    ),
    Message(
      messageType: MessageType.custom,
      id: '12',
      message: jsonEncode(
        customType(
          type: chatExtendType.video,
          data:
              "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        ),
      ),
      createdAt: DateTime.now(),
      sentBy: '2',
      status: MessageStatus.read,
    ),
    Message(
      messageType: MessageType.custom,
      id: '13',
      message: jsonEncode(
        customType(
          type: chatExtendType.video,
          data:
              "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        ),
      ),
      createdAt: DateTime.now(),
      sentBy: '1',
      status: MessageStatus.read,
    ),
  ];
}

enum chatExtendType { video }

class customType {
  chatExtendType type;
  String data;

  customType({required this.type, required this.data});

  Map<String, dynamic> toJson() => {'type': type.toString(), 'data': data};
}

MessageType getRandomMessageType() {
  final values = MessageType.values;
  return values[Mock.number(max: values.length - 1)];
}

class MessageList {
  static Message random(int id, List<Message> dataset) {
    String sender = Mock.number(min: 1, max: 10).toString();
    ReplyMessage? replyMessage;
    Reaction? reaction;
    if (Mock.boolean()) {
      if (dataset.length - 1 > 0) {
        final replyIndex = Mock.number(min: 0, max: dataset.length - 1);
        replyMessage = ReplyMessage(
          messageId: dataset[replyIndex].id,
          message: dataset[replyIndex].message,
          replyBy: sender,
          replyTo: dataset[replyIndex].sentBy,
        );
      }
    }
    if (Mock.boolean()) {
      final int userCount = Mock.number(max: 10);
      List<String> reactions = List.generate(
        userCount,
        (idx) => emojis[Mock.number(max: emojis.length - 1)],
      );
      List<String> userIds = List.generate(
        userCount,
        (idx) => Mock.number(min: 1, max: 10).toString(),
      );
      reaction = Reaction(reactions: reactions, reactedUserIds: userIds);
    }
    final t = getRandomMessageType();
    if (t == MessageType.image) {
      return Message(
        id: id.toString(),
        messageType: MessageType.image,
        message: images[Mock.number(max: images.length - 1)],
        createdAt: DateTime.now(),
        sentBy: sender,
        replyMessage: replyMessage ?? ReplyMessage(),
        reaction: reaction,
      );
    } else if (t == MessageType.voice) {
      // return Message(
      //   id: id.toString(),
      //   messageType: MessageType.voice,
      //   message:
      //       "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      //   createdAt: DateTime.now(),
      //   sentBy: sender,
      //   replyMessage: replyMessage ?? ReplyMessage(),
      //   voiceMessageDuration: Duration(minutes: 6, seconds: 6),
      //   reaction: reaction,
      // );
    } else if (t == MessageType.custom) {
      return Message(
        id: id.toString(),
        messageType: MessageType.custom,
        message: jsonEncode({
          "type": "video",
          "data": videos[Mock.number(max: videos.length - 1)],
        }),
        replyMessage: replyMessage ?? ReplyMessage(),
        createdAt: DateTime.now(),
        sentBy: sender,
        reaction: reaction,
      );
    }
    late String msg;
    if (Mock.boolean()) {
      msg = Mock.text();
    } else {
      msg = "https://bit.ly/3JHS2Wl";
    }
    return Message(
      id: id.toString(),
      message: msg,
      createdAt: DateTime.now(),
      sentBy: sender,
      replyMessage: replyMessage ?? ReplyMessage(),
      reaction: reaction,
    );
  }

  static List<Message> randomList() {
    // return List.generate(Mock.number(min: 5, max: 20), (idx) {
    //   return MessageList.random(idx + 1);
    // });
    List<Message> ret = [];
    for (int i = 1; i < Mock.number(min: 5, max: 20); i++) {
      Message msg = MessageList.random(i, ret);
      ret.add(msg);
    }
    return ret;
  }

  static List<ChatUser> randomUser() {
    return List.generate(10, (idx) {
      return ChatUser(
        id: (idx + 2).toString(),
        name: Mock.username(),
        profilePhoto: Data.profileImage,
      );
    });
  }
}

List<String> videos = [
  "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
  "https://download.samplelib.com/mp4/sample-5s.mp4",
  "https://download.samplelib.com/mp4/sample-5s.mp4",
  "https://filesamples.com/samples/video/mp4/sample_640x360.mp4",
];

List<String> images = [
  "https://miro.medium.com/max/1000/0*s7of7kWnf9fDg4XM.jpeg",
  "https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg",
  "https://www.w3schools.com/w3images/lights.jpg",
  "https://www.w3schools.com/w3images/mountains.jpg",
];

List<String> emojis = [
  '\u{2764}', // ❤️
  '\u{1F600}', // 😀
  '\u{1F602}', // 😂
  '\u{1F609}', // 😉
  '\u{1F60D}', // 😍
  '\u{1F618}', // 😘
  '\u{1F62D}', // 😭
  '\u{1F44D}', // 👍
  '\u{1F525}', // 🔥
  '\u{1F64F}', // 🙏
];
