// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetChatRequest _$GetChatRequestFromJson(Map<String, dynamic> json) =>
    GetChatRequest(
      from: (json['from'] as num).toInt(),
      to: (json['to'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
    );

Map<String, dynamic> _$GetChatRequestToJson(GetChatRequest instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };
