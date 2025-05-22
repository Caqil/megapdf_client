// lib/data/models/rotate_result.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'api_response.dart';

part 'rotate_result.g.dart';

@JsonSerializable()
class RotateResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final String? originalName;
  final BillingInfo? billing;

  const RotateResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.originalName,
    this.billing,
  });

  factory RotateResult.fromJson(Map<String, dynamic> json) =>
      _$RotateResultFromJson(json);

  Map<String, dynamic> toJson() => _$RotateResultToJson(this);

  @override
  List<Object?> get props => [
        success,
        message,
        fileUrl,
        filename,
        originalName,
        billing,
      ];
}

// Rotation options model for requests
@JsonSerializable()
class RotationOptions extends Equatable {
  final int angle;
  final String pages;

  const RotationOptions({
    required this.angle,
    this.pages = 'all',
  });

  factory RotationOptions.fromJson(Map<String, dynamic> json) =>
      _$RotationOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RotationOptionsToJson(this);

  @override
  List<Object?> get props => [angle, pages];
}

enum RotationAngle {
  @JsonValue(90)
  rotate90,
  @JsonValue(180)
  rotate180,
  @JsonValue(270)
  rotate270,
}

extension RotationAngleExtension on RotationAngle {
  int get degrees {
    switch (this) {
      case RotationAngle.rotate90:
        return 90;
      case RotationAngle.rotate180:
        return 180;
      case RotationAngle.rotate270:
        return 270;
    }
  }

  String get displayName {
    switch (this) {
      case RotationAngle.rotate90:
        return '90° Clockwise';
      case RotationAngle.rotate180:
        return '180° Flip';
      case RotationAngle.rotate270:
        return '270° Clockwise';
    }
  }
}

// lib/data/models/page_numbers_result.dart
@JsonSerializable()
class PageNumbersResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? fileName;
  final String? originalName;
  final int? totalPages;
  final int? numberedPages;
  final BillingInfo? billing;

  const PageNumbersResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.fileName,
    this.originalName,
    this.totalPages,
    this.numberedPages,
    this.billing,
  });

  factory PageNumbersResult.fromJson(Map<String, dynamic> json) =>
      _$PageNumbersResultFromJson(json);

  Map<String, dynamic> toJson() => _$PageNumbersResultToJson(this);

  @override
  List<Object?> get props => [
        success,
        message,
        fileUrl,
        fileName,
        originalName,
        totalPages,
        numberedPages,
        billing,
      ];
}
