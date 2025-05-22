import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:megapdf_client/data/models/api_response.dart';

part 'unlock_result.g.dart';

@JsonSerializable()
class UnlockResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final String? originalName;
  final BillingInfo? billing;

  const UnlockResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.originalName,
    this.billing,
  });

  factory UnlockResult.fromJson(Map<String, dynamic> json) =>
      _$UnlockResultFromJson(json);

  Map<String, dynamic> toJson() => _$UnlockResultToJson(this);

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
