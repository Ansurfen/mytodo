// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  (json['id'] as num).toInt(),
  (json['user_id'] as num).toInt(),
  json['username'] as String? ?? '',
  json['is_male'] as bool? ?? false,
  json['title'] as String,
  json['text'] as List<dynamic>,
  string2DateTime(json['created_at'] as String),
  (json['like_count'] as num?)?.toInt() ?? 0,
  (json['comment_count'] as num?)?.toInt() ?? 0,
  (json['visit_count'] as num?)?.toInt() ?? 0,
  json['is_favorite'] as bool? ?? false,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.uid,
  'username': instance.username,
  'is_male': instance.isMale,
  'title': instance.title,
  'text': instance.text,
  'created_at': instance.createAt.toIso8601String(),
  'like_count': instance.likeCount,
  'comment_count': instance.commentCount,
  'visit_count': instance.visitCount,
  'is_favorite': instance.isFavorite,
};

PostComment _$PostCommentFromJson(Map<String, dynamic> json) => PostComment(
  id: (json['id'] as num).toInt(),
  postId: (json['post_id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  replyId: (json['reply_id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  replyName: json['reply_name'] as String? ?? '',
  replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  text: json['text'] as String,
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => PostComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  likeCount: (json['like_count'] as num).toInt(),
  isFavorite: json['is_favorite'] as bool,
);

Map<String, dynamic> _$PostCommentToJson(PostComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'reply_id': instance.replyId,
      'username': instance.username,
      'reply_name': instance.replyName,
      'created_at': instance.createdAt.toIso8601String(),
      'text': instance.text,
      'replies': instance.replies,
      'reply_count': instance.replyCount,
      'like_count': instance.likeCount,
      'is_favorite': instance.isFavorite,
    };
