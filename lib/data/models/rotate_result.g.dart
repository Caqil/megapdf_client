// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rotate_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RotateResult _$RotateResultFromJson(Map<String, dynamic> json) => RotateResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String?,
      filename: json['filename'] as String?,
      originalName: json['originalName'] as String?,
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RotateResultToJson(RotateResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'billing': instance.billing,
    };

RotationOptions _$RotationOptionsFromJson(Map<String, dynamic> json) =>
    RotationOptions(
      angle: (json['angle'] as num).toInt(),
      pages: json['pages'] as String? ?? 'all',
    );

Map<String, dynamic> _$RotationOptionsToJson(RotationOptions instance) =>
    <String, dynamic>{
      'angle': instance.angle,
      'pages': instance.pages,
    };

PageNumbersResult _$PageNumbersResultFromJson(Map<String, dynamic> json) =>
    PageNumbersResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      originalName: json['originalName'] as String?,
      totalPages: (json['totalPages'] as num?)?.toInt(),
      numberedPages: (json['numberedPages'] as num?)?.toInt(),
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PageNumbersResultToJson(PageNumbersResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'fileName': instance.fileName,
      'originalName': instance.originalName,
      'totalPages': instance.totalPages,
      'numberedPages': instance.numberedPages,
      'billing': instance.billing,
    };
