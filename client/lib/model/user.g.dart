// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  isMale: json['is_male'] as bool? ?? true,
  isOnline: json['is_online'] as bool? ?? false,
  postCount: (json['post_count'] as num?)?.toInt() ?? 0,
  topicCount: (json['topic_count'] as num?)?.toInt() ?? 0,
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'is_male': instance.isMale,
      'is_online': instance.isOnline,
      'post_count': instance.postCount,
      'topic_count': instance.topicCount,
      'follower_count': instance.followerCount,
    };

Chatsnapshot _$ChatsnapshotFromJson(Map<String, dynamic> json) => Chatsnapshot(
  unreaded: (json['unreaded'] as num?)?.toInt() ?? 0,
  lastAt: DateTime.parse(json['last_at'] as String),
  lastSenderName: json['last_sender_name'] as String,
  lastMsg: json['last_message'] as String,
  lastMsgId: (json['last_message_id'] as num).toInt(),
  name: json['name'] as String,
  id: (json['id'] as num).toInt(),
  isOnline: json['is_online'] as bool? ?? false,
  isTopic: json['is_topic'] as bool? ?? false,
);

Map<String, dynamic> _$ChatsnapshotToJson(Chatsnapshot instance) =>
    <String, dynamic>{
      'unreaded': instance.unreaded,
      'last_at': instance.lastAt.toIso8601String(),
      'last_sender_name': instance.lastSenderName,
      'last_message': instance.lastMsg,
      'last_message_id': instance.lastMsgId,
      'name': instance.name,
      'id': instance.id,
      'is_online': instance.isOnline,
      'is_topic': instance.isTopic,
    };
