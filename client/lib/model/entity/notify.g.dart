// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notify.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notify _$NotifyFromJson(Map<String, dynamic> json) => Notify(
      id: json['id'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      param: json['param'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );

Map<String, dynamic> _$NotifyToJson(Notify instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'param': instance.param,
      'title': instance.title,
      'content': instance.content,
    };
