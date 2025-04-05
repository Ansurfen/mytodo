// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitTaskRequest _$CommitTaskRequestFromJson(Map<String, dynamic> json) =>
    CommitTaskRequest(
      (json['tid'] as num).toInt(),
      (json['type'] as num).toInt(),
      json['param'] as String,
    );

Map<String, dynamic> _$CommitTaskRequestToJson(CommitTaskRequest instance) =>
    <String, dynamic>{
      'tid': instance.task,
      'type': instance.type,
      'param': instance.param,
    };

TaskHasPermRequest _$TaskHasPermRequestFromJson(Map<String, dynamic> json) =>
    TaskHasPermRequest(tid: (json['tid'] as num).toInt());

Map<String, dynamic> _$TaskHasPermRequestToJson(TaskHasPermRequest instance) =>
    <String, dynamic>{'tid': instance.tid};
