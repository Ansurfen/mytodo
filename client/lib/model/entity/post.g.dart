// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  (json['uid'] as num).toInt(),
  json['content'] as String,
  dateTimeString2Int(json['created_at'] as String),
  (json['deleted_at'] as num?)?.toInt() ?? 0,
  MImage.imagesFromJson(json['image'] as List?),
)..id = (json['id'] as num?)?.toInt();

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'uid': instance.uid,
  'content': instance.content,
  'created_at': instance.createAt,
  'deleted_at': instance.deleteAt,
  'image': instance.images,
};

PostComment _$PostCommentFromJson(Map<String, dynamic> json) => PostComment(
  id: (json['id'] as num?)?.toInt() ?? 0,
  pid: (json['pid'] as num?)?.toInt() ?? 0,
  uid: (json['uid'] as num?)?.toInt() ?? 0,
  reply: (json['reply'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  replyName: json['reply_name'] as String? ?? '',
  createdAt: DateTime.parse(json['created_at'] as String),
  content: (json['content'] as List<dynamic>).map((e) => e as String).toList(),
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => PostComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  favorite: (json['favorite'] as num?)?.toInt() ?? 0,
  youFavorite: json['you_favorite'] as bool? ?? false,
);

Map<String, dynamic> _$PostCommentToJson(PostComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pid': instance.pid,
      'uid': instance.uid,
      'reply': instance.reply,
      'username': instance.username,
      'reply_name': instance.replyName,
      'created_at': instance.createdAt.toIso8601String(),
      'content': instance.content,
      'replies': instance.replies,
      'favorite': instance.favorite,
      'images': instance.images,
      'you_favorite': instance.youFavorite,
    };
