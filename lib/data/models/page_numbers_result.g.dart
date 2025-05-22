// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_numbers_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageNumberingOptions _$PageNumberingOptionsFromJson(
        Map<String, dynamic> json) =>
    PageNumberingOptions(
      position: json['position'] as String? ?? 'bottom-center',
      format: json['format'] as String? ?? 'numeric',
      fontFamily: json['fontFamily'] as String? ?? 'Helvetica',
      fontSize: (json['fontSize'] as num?)?.toInt() ?? 12,
      color: json['color'] as String? ?? '#000000',
      startNumber: (json['startNumber'] as num?)?.toInt() ?? 1,
      prefix: json['prefix'] as String? ?? '',
      suffix: json['suffix'] as String? ?? '',
      marginX: (json['marginX'] as num?)?.toInt() ?? 40,
      marginY: (json['marginY'] as num?)?.toInt() ?? 30,
      selectedPages: json['selectedPages'] as String? ?? '',
      skipFirstPage: json['skipFirstPage'] as bool? ?? false,
    );

Map<String, dynamic> _$PageNumberingOptionsToJson(
        PageNumberingOptions instance) =>
    <String, dynamic>{
      'position': instance.position,
      'format': instance.format,
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'color': instance.color,
      'startNumber': instance.startNumber,
      'prefix': instance.prefix,
      'suffix': instance.suffix,
      'marginX': instance.marginX,
      'marginY': instance.marginY,
      'selectedPages': instance.selectedPages,
      'skipFirstPage': instance.skipFirstPage,
    };
