import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'api_response.dart';

part 'compress_result.g.dart';

@JsonSerializable()
class CompressResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final String? originalName;
  final int? originalSize;
  final int? compressedSize;
  final String? compressionRatio;
  final BillingInfo? billing;

  const CompressResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.originalName,
    this.originalSize,
    this.compressedSize,
    this.compressionRatio,
    this.billing,
  });

  factory CompressResult.fromJson(Map<String, dynamic> json) =>
      _$CompressResultFromJson(json);

  Map<String, dynamic> toJson() => _$CompressResultToJson(this);

  // Convenience getters
  double get compressionPercentage {
    if (compressionRatio == null) return 0.0;
    final ratioStr = compressionRatio!.replaceAll('%', '');
    return double.tryParse(ratioStr) ?? 0.0;
  }

  String get formattedOriginalSize {
    if (originalSize == null) return 'Unknown';
    return _formatFileSize(originalSize!);
  }

  String get formattedCompressedSize {
    if (compressedSize == null) return 'Unknown';
    return _formatFileSize(compressedSize!);
  }

  String get savedSpace {
    if (originalSize == null || compressedSize == null) return 'Unknown';
    final saved = originalSize! - compressedSize!;
    return _formatFileSize(saved);
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
        originalSize,
        compressedSize,
        compressionRatio,
        billing,
      ];
}
