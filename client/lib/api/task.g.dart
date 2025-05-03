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
      dailyFinished: (json['daily_finished'] as num).toInt(),
      dailyTotal: (json['daily_total'] as num).toInt(),
      monthlyFinished: (json['monthly_finished'] as num).toInt(),
      monthlyTotal: (json['monthly_total'] as num).toInt(),
      yearlyFinished: (json['yearly_finished'] as num).toInt(),
      yearlyTotal: (json['yearly_total'] as num).toInt(),
    );

Map<String, dynamic> _$TaskDashboardStatsToJson(TaskDashboardStats instance) =>
    <String, dynamic>{
      'completed': instance.completed,
      'overdue': instance.overdue,
      'in_progress': instance.inProgress,
      'daily_finished': instance.dailyFinished,
      'daily_total': instance.dailyTotal,
      'monthly_finished': instance.monthlyFinished,
      'monthly_total': instance.monthlyTotal,
      'yearly_finished': instance.yearlyFinished,
      'yearly_total': instance.yearlyTotal,
    };
