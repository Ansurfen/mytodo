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

TaskDashboardStats _$TaskDashboardStatsFromJson(Map<String, dynamic> json) =>
    TaskDashboardStats(
      completed: (json['completed'] as num).toInt(),
      overdue: (json['overdue'] as num).toInt(),
      inProgress: (json['in_progress'] as num).toInt(),
      daily: (json['daily'] as num).toInt(),
      monthly: (json['monthly'] as num).toInt(),
      yearly: (json['yearly'] as num).toInt(),
    );

Map<String, dynamic> _$TaskDashboardStatsToJson(TaskDashboardStats instance) =>
    <String, dynamic>{
      'completed': instance.completed,
      'overdue': instance.overdue,
      'in_progress': instance.inProgress,
      'daily': instance.daily,
      'monthly': instance.monthly,
      'yearly': instance.yearly,
    };
