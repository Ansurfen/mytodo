// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      id: json['_id'] as String? ?? '',
      from: json['from'] as int,
      to: json['to'] as int,
      reply: json['reply'] as String? ?? '',
      replyContent: json['reply_content'] as String? ?? '',
      content:
          (json['content'] as List<dynamic>).map((e) => e as String).toList(),
      time: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      '_id': instance.id,
      'from': instance.from,
      'to': instance.to,
      'reply': instance.reply,
      'reply_content': instance.replyContent,
      'content': instance.content,
    };
