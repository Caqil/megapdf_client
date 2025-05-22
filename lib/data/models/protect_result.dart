// lib/data/models/protect_result.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'api_response.dart';

part 'protect_result.g.dart';

@JsonSerializable()
class ProtectResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final String? originalName;
  final String? methodUsed;
  final BillingInfo? billing;

  const ProtectResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.originalName,
    this.methodUsed,
    this.billing,
  });

  factory ProtectResult.fromJson(Map<String, dynamic> json) =>
      _$ProtectResultFromJson(json);

  Map<String, dynamic> toJson() => _$ProtectResultToJson(this);

  @override
  List<Object?> get props => [
        success,
        message,
        fileUrl,
        filename,
        originalName,
        methodUsed,
        billing,
      ];
}

// Protection options model for requests
@JsonSerializable()
class ProtectionOptions extends Equatable {
  final String password;
  final String permission;
  final bool allowPrinting;
  final bool allowCopying;
  final bool allowEditing;

  const ProtectionOptions({
    required this.password,
    this.permission = 'restricted',
    this.allowPrinting = false,
    this.allowCopying = false,
    this.allowEditing = false,
  });

  factory ProtectionOptions.fromJson(Map<String, dynamic> json) =>
      _$ProtectionOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$ProtectionOptionsToJson(this);

  @override
  List<Object?> get props => [
        password,
        permission,
        allowPrinting,
        allowCopying,
        allowEditing,
      ];
}
