import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final String? error;
  final T? data;
  final Map<String, dynamic>? details;

  const ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.data,
    this.details,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Factory constructors for common responses
  factory ApiResponse.success({
    String? message,
    T? data,
  }) =>
      ApiResponse(
        success: true,
        message: message,
        data: data,
      );

  factory ApiResponse.error({
    required String error,
    Map<String, dynamic>? details,
  }) =>
      ApiResponse(
        success: false,
        error: error,
        details: details,
      );

  @override
  List<Object?> get props => [success, message, error, data, details];
}

// Base operation result
@JsonSerializable()
class BaseOperationResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final String? originalName;
  final BillingInfo? billing;

  const BaseOperationResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.originalName,
    this.billing,
  });

  factory BaseOperationResult.fromJson(Map<String, dynamic> json) =>
      _$BaseOperationResultFromJson(json);

  Map<String, dynamic> toJson() => _$BaseOperationResultToJson(this);

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

// Billing information (included in responses but not tracked)
@JsonSerializable()
class BillingInfo extends Equatable {
  final bool? usedFreeOperation;
  final int? freeOperationsRemaining;
  final double? currentBalance;
  final double? operationCost;

  const BillingInfo({
    this.usedFreeOperation,
    this.freeOperationsRemaining,
    this.currentBalance,
    this.operationCost,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) =>
      _$BillingInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BillingInfoToJson(this);

  @override
  List<Object?> get props => [
        usedFreeOperation,
        freeOperationsRemaining,
        currentBalance,
        operationCost,
      ];
}
