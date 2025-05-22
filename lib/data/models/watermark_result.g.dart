// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watermark_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatermarkResult _$WatermarkResultFromJson(Map<String, dynamic> json) =>
    WatermarkResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String?,
      filename: json['filename'] as String?,
      originalName: json['originalName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WatermarkResultToJson(WatermarkResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'fileSize': instance.fileSize,
      'billing': instance.billing,
    };

WatermarkOptions _$WatermarkOptionsFromJson(Map<String, dynamic> json) =>
    WatermarkOptions(
      watermarkType: $enumDecode(_$WatermarkTypeEnumMap, json['watermarkType']),
      text: json['text'] as String?,
      textColor: json['textColor'] as String? ?? '#FF0000',
      fontSize: (json['fontSize'] as num?)?.toInt() ?? 48,
      fontFamily: json['fontFamily'] as String? ?? 'Helvetica',
      position:
          $enumDecodeNullable(_$WatermarkPositionEnumMap, json['position']) ??
              WatermarkPosition.center,
      rotation: (json['rotation'] as num?)?.toInt() ?? 0,
      opacity: (json['opacity'] as num?)?.toInt() ?? 30,
      scale: (json['scale'] as num?)?.toInt() ?? 50,
      pages: json['pages'] as String? ?? 'all',
      customPages: json['customPages'] as String?,
      customX: (json['customX'] as num?)?.toInt(),
      customY: (json['customY'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WatermarkOptionsToJson(WatermarkOptions instance) =>
    <String, dynamic>{
      'watermarkType': _$WatermarkTypeEnumMap[instance.watermarkType]!,
      'text': instance.text,
      'textColor': instance.textColor,
      'fontSize': instance.fontSize,
      'fontFamily': instance.fontFamily,
      'position': _$WatermarkPositionEnumMap[instance.position]!,
      'rotation': instance.rotation,
      'opacity': instance.opacity,
      'scale': instance.scale,
      'pages': instance.pages,
      'customPages': instance.customPages,
      'customX': instance.customX,
      'customY': instance.customY,
    };

const _$WatermarkTypeEnumMap = {
  WatermarkType.text: 'text',
  WatermarkType.image: 'image',
  WatermarkType.pdf: 'pdf',
};

const _$WatermarkPositionEnumMap = {
  WatermarkPosition.center: 'center',
  WatermarkPosition.topLeft: 'top-left',
  WatermarkPosition.topRight: 'top-right',
  WatermarkPosition.bottomLeft: 'bottom-left',
  WatermarkPosition.bottomRight: 'bottom-right',
  WatermarkPosition.custom: 'custom',
  WatermarkPosition.tile: 'tile',
};
