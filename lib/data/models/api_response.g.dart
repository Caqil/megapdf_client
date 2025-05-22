// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      error: json['error'] as String?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error': instance.error,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'details': instance.details,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

BaseOperationResult _$BaseOperationResultFromJson(Map<String, dynamic> json) =>
    BaseOperationResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String?,
      filename: json['filename'] as String?,
      originalName: json['originalName'] as String?,
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BaseOperationResultToJson(
        BaseOperationResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'billing': instance.billing,
    };

BillingInfo _$BillingInfoFromJson(Map<String, dynamic> json) => BillingInfo(
      usedFreeOperation: json['usedFreeOperation'] as bool?,
      freeOperationsRemaining:
          (json['freeOperationsRemaining'] as num?)?.toInt(),
      currentBalance: (json['currentBalance'] as num?)?.toDouble(),
      operationCost: (json['operationCost'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BillingInfoToJson(BillingInfo instance) =>
    <String, dynamic>{
      'usedFreeOperation': instance.usedFreeOperation,
      'freeOperationsRemaining': instance.freeOperationsRemaining,
      'currentBalance': instance.currentBalance,
      'operationCost': instance.operationCost,
    };
