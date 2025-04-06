// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'description', 'start_at', 'end_at'],
  );
  return Task(
    (json['id'] as num?)?.toInt() ?? 0,
    json['name'] as String? ?? '',
    json['description'] as String? ?? '',
    string2DateTime(json['start_at'] as String),
    string2DateTime(json['end_at'] as String),
    user: (json['user'] as num?)?.toInt() ?? 0,
  );
}

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'name': instance.name,
  'description': instance.description,
  'start_at': instance.startAt.toIso8601String(),
  'end_at': instance.endAt.toIso8601String(),
};
