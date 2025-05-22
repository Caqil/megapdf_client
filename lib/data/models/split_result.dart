import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'api_response.dart';

part 'split_result.g.dart';

@JsonSerializable()
class SplitResult extends Equatable {
  final bool success;
  final String message;
  final String? originalName;
  final int? totalPages;
  final List<SplitPart>? splitParts;
  final bool? isLargeJob;
  final String? jobId;
  final String? statusUrl;
  final int? estimatedSplits;
  final BillingInfo? billing;

  const SplitResult({
    required this.success,
    required this.message,
    this.originalName,
    this.totalPages,
    this.splitParts,
    this.isLargeJob,
    this.jobId,
    this.statusUrl,
    this.estimatedSplits,
    this.billing,
  });

  factory SplitResult.fromJson(Map<String, dynamic> json) =>
      _$SplitResultFromJson(json);

  Map<String, dynamic> toJson() => _$SplitResultToJson(this);

  // Convenience getters
  bool get isAsyncJob => isLargeJob == true && jobId != null;
  int get actualSplitCount => splitParts?.length ?? 0;

  @override
  List<Object?> get props => [
        success,
        message,
        originalName,
        totalPages,
        splitParts,
        isLargeJob,
        jobId,
        statusUrl,
        estimatedSplits,
        billing,
      ];
}

@JsonSerializable()
class SplitPart extends Equatable {
  final String fileUrl;
  final String filename;
  final List<int> pages;
  final int pageCount;

  const SplitPart({
    required this.fileUrl,
    required this.filename,
    required this.pages,
    required this.pageCount,
  });

  factory SplitPart.fromJson(Map<String, dynamic> json) =>
      _$SplitPartFromJson(json);

  Map<String, dynamic> toJson() => _$SplitPartToJson(this);

  // Convenience getters
  String get pageRange {
    if (pages.isEmpty) return '';
    if (pages.length == 1) return pages.first.toString();

    // Sort pages and create ranges
    final sortedPages = [...pages]..sort();
    final ranges = <String>[];
    int start = sortedPages.first;
    int end = start;

    for (int i = 1; i < sortedPages.length; i++) {
      if (sortedPages[i] == end + 1) {
        end = sortedPages[i];
      } else {
        if (start == end) {
          ranges.add(start.toString());
        } else {
          ranges.add('$start-$end');
        }
        start = sortedPages[i];
        end = start;
      }
    }

    // Add the last range
    if (start == end) {
      ranges.add(start.toString());
    } else {
      ranges.add('$start-$end');
    }

    return ranges.join(', ');
  }

  @override
  List<Object?> get props => [fileUrl, filename, pages, pageCount];
}
