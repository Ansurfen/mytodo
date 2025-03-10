// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSnapshotDTO _$ChatSnapshotDTOFromJson(Map<String, dynamic> json) =>
    ChatSnapshotDTO(
      count: (json['count'] as num?)?.toInt() ?? 0,
      lastAt: DateTime.parse(json['lastAt'] as String),
      lastMsg:
          (json['lastMsg'] as List<dynamic>).map((e) => e as String).toList(),
      username: json['username'] as String,
      uid: (json['uid'] as num).toInt(),
    );

Map<String, dynamic> _$ChatSnapshotDTOToJson(ChatSnapshotDTO instance) =>
    <String, dynamic>{
      'count': instance.count,
      'lastAt': instance.lastAt.toIso8601String(),
      'lastMsg': instance.lastMsg,
      'username': instance.username,
      'uid': instance.uid,
    };
