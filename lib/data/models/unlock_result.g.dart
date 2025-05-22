// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnlockResult _$UnlockResultFromJson(Map<String, dynamic> json) => UnlockResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String?,
      filename: json['filename'] as String?,
      originalName: json['originalName'] as String?,
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnlockResultToJson(UnlockResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'billing': instance.billing,
    };
