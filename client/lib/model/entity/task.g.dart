// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'desc', 'departure', 'arrival'],
  );
  return Task(
    json['name'] as String? ?? '',
    json['desc'] as String? ?? '',
    (json['departure'] as num?)?.toInt() ?? 0,
    (json['arrival'] as num?)?.toInt() ?? 0,
    id: (json['id'] as num?)?.toInt() ?? 0,
    user: (json['user'] as num?)?.toInt() ?? 0,
  );
}

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'name': instance.name,
  'desc': instance.desc,
  'departure': instance.startAt,
  'arrival': instance.endAt,
};
