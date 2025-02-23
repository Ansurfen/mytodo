// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetChatRequest _$GetChatRequestFromJson(Map<String, dynamic> json) =>
    GetChatRequest(
      from: json['from'] as int,
      to: json['to'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );

Map<String, dynamic> _$GetChatRequestToJson(GetChatRequest instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };
