import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'api_response.dart';

part 'merge_result.g.dart';

@JsonSerializable()
class MergeResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final int? mergedSize;
  final int? totalInputSize;
  final int? fileCount;
  final BillingInfo? billing;

  const MergeResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.mergedSize,
    this.totalInputSize,
    this.fileCount,
    this.billing,
  });

  factory MergeResult.fromJson(Map<String, dynamic> json) =>
      _$MergeResultFromJson(json);

  Map<String, dynamic> toJson() => _$MergeResultToJson(this);

  // Convenience getters
  String get formattedMergedSize {
    if (mergedSize == null) return 'Unknown';
    return _formatFileSize(mergedSize!);
  }

  String get formattedTotalInputSize {
    if (totalInputSize == null) return 'Unknown';
    return _formatFileSize(totalInputSize!);
  }

  double get compressionRatio {
    if (mergedSize == null || totalInputSize == null || totalInputSize == 0) {
      return 0.0;
    }
    return ((totalInputSize! - mergedSize!) / totalInputSize!) * 100;
  }

  String get compressionInfo {
    final ratio = compressionRatio;
    if (ratio > 0) {
      return 'Size reduced by ${ratio.toStringAsFixed(1)}%';
    } else if (ratio < 0) {
      return 'Size increased by ${(-ratio).toStringAsFixed(1)}%';
    } else {
      return 'No size change';
    }
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
        mergedSize,
        totalInputSize,
        fileCount,
        billing,
      ];
}
