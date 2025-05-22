// lib/data/models/split_options.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'split_options.g.dart';

@JsonSerializable()
class SplitOptions extends Equatable {
  final SplitMethod splitMethod;
  final String? pageRanges;
  final int? everyNPages;

  const SplitOptions({
    required this.splitMethod,
    this.pageRanges,
    this.everyNPages,
  });

  factory SplitOptions.fromJson(Map<String, dynamic> json) =>
      _$SplitOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$SplitOptionsToJson(this);

  // Factory constructors for different split methods
  factory SplitOptions.byRange(String pageRanges) {
    return SplitOptions(
      splitMethod: SplitMethod.range,
      pageRanges: pageRanges,
    );
  }

  factory SplitOptions.extractAll() {
    return const SplitOptions(
      splitMethod: SplitMethod.extract,
    );
  }

  factory SplitOptions.everyNPages(int n) {
    return SplitOptions(
      splitMethod: SplitMethod.every,
      everyNPages: n,
    );
  }

  @override
  List<Object?> get props => [splitMethod, pageRanges, everyNPages];
}

enum SplitMethod {
  @JsonValue('range')
  range,
  @JsonValue('extract')
  extract,
  @JsonValue('every')
  every,
}

extension SplitMethodExtension on SplitMethod {
  String get displayName {
    switch (this) {
      case SplitMethod.range:
        return 'Custom Ranges';
      case SplitMethod.extract:
        return 'Extract All Pages';
      case SplitMethod.every:
        return 'Every N Pages';
    }
  }

  String get description {
    switch (this) {
      case SplitMethod.range:
        return 'Split by specific page ranges (e.g., 1-3, 5, 7-9)';
      case SplitMethod.extract:
        return 'Extract each page as a separate PDF';
      case SplitMethod.every:
        return 'Split into chunks of N pages each';
    }
  }

  String get value {
    return toString().split('.').last;
  }
}
