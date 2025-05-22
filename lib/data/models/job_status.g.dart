// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobStatus _$JobStatusFromJson(Map<String, dynamic> json) => JobStatus(
      id: json['id'] as String,
      status: $enumDecode(_$JobStatusTypeEnumMap, json['status']),
      progress: (json['progress'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => SplitPart.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$JobStatusToJson(JobStatus instance) => <String, dynamic>{
      'id': instance.id,
      'status': _$JobStatusTypeEnumMap[instance.status]!,
      'progress': instance.progress,
      'total': instance.total,
      'completed': instance.completed,
      'results': instance.results,
      'error': instance.error,
    };

const _$JobStatusTypeEnumMap = {
  JobStatusType.processing: 'processing',
  JobStatusType.completed: 'completed',
  JobStatusType.error: 'error',
};
