// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SplitResult _$SplitResultFromJson(Map<String, dynamic> json) => SplitResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      originalName: json['originalName'] as String?,
      totalPages: (json['totalPages'] as num?)?.toInt(),
      splitParts: (json['splitParts'] as List<dynamic>?)
          ?.map((e) => SplitPart.fromJson(e as Map<String, dynamic>))
          .toList(),
      isLargeJob: json['isLargeJob'] as bool?,
      jobId: json['jobId'] as String?,
      statusUrl: json['statusUrl'] as String?,
      estimatedSplits: (json['estimatedSplits'] as num?)?.toInt(),
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SplitResultToJson(SplitResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'originalName': instance.originalName,
      'totalPages': instance.totalPages,
      'splitParts': instance.splitParts,
      'isLargeJob': instance.isLargeJob,
      'jobId': instance.jobId,
      'statusUrl': instance.statusUrl,
      'estimatedSplits': instance.estimatedSplits,
      'billing': instance.billing,
    };

SplitPart _$SplitPartFromJson(Map<String, dynamic> json) => SplitPart(
      fileUrl: json['fileUrl'] as String,
      filename: json['filename'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      pageCount: (json['pageCount'] as num).toInt(),
    );

Map<String, dynamic> _$SplitPartToJson(SplitPart instance) => <String, dynamic>{
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'pages': instance.pages,
      'pageCount': instance.pageCount,
    };
