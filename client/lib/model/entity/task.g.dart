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
    json['departure'] as int? ?? 0,
    json['arrival'] as int? ?? 0,
    id: json['id'] as int? ?? 0,
    user: json['user'] as int? ?? 0,
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

TaskCondition _$TaskConditionFromJson(Map<String, dynamic> json) =>
    TaskCondition(
      json['type'] as int,
      json['param'] as String,
    );

Map<String, dynamic> _$TaskConditionToJson(TaskCondition instance) =>
    <String, dynamic>{
      'type': instance.type,
      'param': instance.param,
    };
