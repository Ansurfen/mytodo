// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notify.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notify _$NotifyFromJson(Map<String, dynamic> json) => Notify(
  id: (json['id'] as num?)?.toInt() ?? 0,
  type: (json['type'] as num?)?.toInt() ?? 0,
  status: (json['status'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  sender: json['sender'] as String,
  uid: (json['uid'] as num?)?.toInt() ?? 0,
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
  'sender': instance.sender,
  'uid': instance.uid,
};
