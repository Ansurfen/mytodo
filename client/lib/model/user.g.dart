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
