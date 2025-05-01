import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/utils/json.dart';

part 'user.g.dart';

@JsonSerializable()
class UserProfile {
  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "description")
  String description;

  @JsonKey(name: "is_male", defaultValue: true)
  bool isMale;

  @JsonKey(name: "is_online", defaultValue: false)
  bool isOnline;

  @JsonKey(name: "post_count", defaultValue: 0)
  int postCount;

  @JsonKey(name: "topic_count", defaultValue: 0)
  int topicCount;

  @JsonKey(name: "follower_count", defaultValue: 0)
  int followerCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.isMale,
    required this.isOnline,
    required this.postCount,
    required this.topicCount,
    required this.followerCount,
  });

  static UserProfile random(int id) {
    return UserProfile(
      id: id,
      name: Mock.username(),
      description: Mock.text(),
      isMale: Mock.boolean(),
      isOnline: Mock.boolean(),
      postCount: Mock.number(),
      topicCount: Mock.number(),
      followerCount: Mock.number(),
    );
  }

  static UserProfile fromJson(JsonObject json) => _$UserProfileFromJson(json);
}

@JsonSerializable()
class Chatsnapshot {
  @JsonKey(name: "unreaded", defaultValue: 0)
  int unreaded;

  @JsonKey(name: "last_at")
  DateTime lastAt;

  @JsonKey(name: "last_sender_name")
  String lastSenderName;

  @JsonKey(name: "last_message")
  String lastMsg;

  @JsonKey(name: "last_message_id")
  int lastMsgId;

  // topic or username
  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "is_online", defaultValue: false)
  bool isOnline;

  @JsonKey(name: "is_topic", defaultValue: false)
  bool isTopic;

  Chatsnapshot({
    required this.unreaded,
    required this.lastAt,
    required this.lastSenderName,
    required this.lastMsg,
    required this.lastMsgId,
    required this.name,
    required this.id,
    required this.isOnline,
    required this.isTopic,
  });

  static Chatsnapshot random() {
    return Chatsnapshot(
      unreaded: Mock.number(max: 100),
      lastAt: DateTime.now().subtract(
        Duration(seconds: Mock.number(max: 100000)),
      ),
      lastMsg: Mock.text(),
      name: Mock.username(),
      id: Mock.number(),
      isOnline: Mock.boolean(),
      isTopic: Mock.boolean(),
      lastSenderName: Mock.username(),
      lastMsgId: Mock.number(),
    );
  }

  static List<Chatsnapshot> randomList() {
    return List.generate(
      Mock.number(min: 5, max: 20),
      (index) => Chatsnapshot.random(),
    );
  }

  static Chatsnapshot fromJson(JsonObject json) => _$ChatsnapshotFromJson(json);
}
