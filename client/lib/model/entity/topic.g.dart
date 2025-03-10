// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  (json['user'] as num).toInt(),
  json['name'] as String,
  json['desc'] as String,
)..id = (json['id'] as num?)?.toInt();

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'name': instance.name,
  'desc': instance.desc,
};

TopicMember _$TopicMemberFromJson(Map<String, dynamic> json) =>
    TopicMember(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$TopicMemberToJson(TopicMember instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
