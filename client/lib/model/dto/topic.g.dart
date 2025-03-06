// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTopicDto _$GetTopicDtoFromJson(Map<String, dynamic> json) => GetTopicDto(
  json['id'] as int? ?? 0,
  DateTime.parse(json['created_at'] as String),
  DateTime.parse(json['deleted_at'] as String),
  json['name'] as String,
  json['desc'] as String,
  json['invite_code'] as String,
  json['icon'] as String,
);

Map<String, dynamic> _$GetTopicDtoToJson(GetTopicDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createAt.toIso8601String(),
      'deleted_at': instance.deleteAt.toIso8601String(),
      'name': instance.name,
      'desc': instance.desc,
      'invite_code': instance.inviteCode,
    };
