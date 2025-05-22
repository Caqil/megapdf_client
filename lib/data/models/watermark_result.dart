import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'api_response.dart';

part 'watermark_result.g.dart';

@JsonSerializable()
class WatermarkResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final String? originalName;
  final int? fileSize;
  final BillingInfo? billing;

  const WatermarkResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.originalName,
    this.fileSize,
    this.billing,
  });

  factory WatermarkResult.fromJson(Map<String, dynamic> json) =>
      _$WatermarkResultFromJson(json);

  Map<String, dynamic> toJson() => _$WatermarkResultToJson(this);

  // Convenience getters
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    return _formatFileSize(fileSize!);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  List<Object?> get props => [
        success,
        message,
        fileUrl,
        filename,
        originalName,
        fileSize,
        billing,
      ];
}

// Watermark configuration models for requests
@JsonSerializable()
class WatermarkOptions extends Equatable {
  final WatermarkType watermarkType;
  final String? text;
  final String? textColor;
  final int? fontSize;
  final String? fontFamily;
  final WatermarkPosition position;
  final int? rotation;
  final int? opacity;
  final int? scale;
  final String? pages;
  final String? customPages;
  final int? customX;
  final int? customY;

  const WatermarkOptions({
    required this.watermarkType,
    this.text,
    this.textColor = '#FF0000',
    this.fontSize = 48,
    this.fontFamily = 'Helvetica',
    this.position = WatermarkPosition.center,
    this.rotation = 0,
    this.opacity = 30,
    this.scale = 50,
    this.pages = 'all',
    this.customPages,
    this.customX,
    this.customY,
  });

  factory WatermarkOptions.fromJson(Map<String, dynamic> json) =>
      _$WatermarkOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$WatermarkOptionsToJson(this);

  @override
  List<Object?> get props => [
        watermarkType,
        text,
        textColor,
        fontSize,
        fontFamily,
        position,
        rotation,
        opacity,
        scale,
        pages,
        customPages,
        customX,
        customY,
      ];
}

enum WatermarkType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('pdf')
  pdf,
}

enum WatermarkPosition {
  @JsonValue('center')
  center,
  @JsonValue('top-left')
  topLeft,
  @JsonValue('top-right')
  topRight,
  @JsonValue('bottom-left')
  bottomLeft,
  @JsonValue('bottom-right')
  bottomRight,
  @JsonValue('custom')
  custom,
  @JsonValue('tile')
  tile,
}
