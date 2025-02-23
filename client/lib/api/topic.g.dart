// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTopicRequest _$CreateTopicRequestFromJson(Map<String, dynamic> json) =>
    CreateTopicRequest(
      json['name'] as String? ?? '',
      json['desc'] as String? ?? '',
    );

Map<String, dynamic> _$CreateTopicRequestToJson(CreateTopicRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'desc': instance.desc,
    };

SubscribeTopicRequest _$SubscribeTopicRequestFromJson(
        Map<String, dynamic> json) =>
    SubscribeTopicRequest(
      code: json['invite_code'] as String,
    );

Map<String, dynamic> _$SubscribeTopicRequestToJson(
        SubscribeTopicRequest instance) =>
    <String, dynamic>{
      'invite_code': instance.code,
    };

GetSubscribedMemberRequest _$GetSubscribedMemberRequestFromJson(
        Map<String, dynamic> json) =>
    GetSubscribedMemberRequest(
      id: json['id'] as int,
    );

Map<String, dynamic> _$GetSubscribedMemberRequestToJson(
        GetSubscribedMemberRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
    };
