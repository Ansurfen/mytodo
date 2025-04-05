// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  json['icon'] as String,
  (json['id'] as num).toInt(),
  (json['creator'] as num).toInt(),
  json['name'] as String,
  json['description'] as String,
  (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  json['invite_code'] as String,
);

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'icon': instance.icon,
  'id': instance.id,
  'creator': instance.creator,
  'name': instance.name,
  'description': instance.description,
  'tags': instance.tags,
  'invite_code': instance.inviteCode,
};

TopicMember _$TopicMemberFromJson(Map<String, dynamic> json) =>
    TopicMember(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$TopicMemberToJson(TopicMember instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
