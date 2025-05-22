// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compress_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompressResult _$CompressResultFromJson(Map<String, dynamic> json) =>
    CompressResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String?,
      filename: json['filename'] as String?,
      originalName: json['originalName'] as String?,
      originalSize: (json['originalSize'] as num?)?.toInt(),
      compressedSize: (json['compressedSize'] as num?)?.toInt(),
      compressionRatio: json['compressionRatio'] as String?,
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CompressResultToJson(CompressResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'originalSize': instance.originalSize,
      'compressedSize': instance.compressedSize,
      'compressionRatio': instance.compressionRatio,
      'billing': instance.billing,
    };
