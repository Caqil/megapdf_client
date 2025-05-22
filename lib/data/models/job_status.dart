import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'split_result.dart';

part 'job_status.g.dart';

@JsonSerializable()
class JobStatus extends Equatable {
  final String id;
  final JobStatusType status;
  final int progress;
  final int total;
  final int completed;
  final List<SplitPart> results;
  final String? error;

  const JobStatus({
    required this.id,
    required this.status,
    required this.progress,
    required this.total,
    required this.completed,
    required this.results,
    this.error,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) =>
      _$JobStatusFromJson(json);

  Map<String, dynamic> toJson() => _$JobStatusToJson(this);

  // Convenience getters
  bool get isCompleted => status == JobStatusType.completed;
  bool get isProcessing => status == JobStatusType.processing;
  bool get isError => status == JobStatusType.error;
  bool get hasResults => results.isNotEmpty;

  double get progressPercentage => progress / 100.0;

  String get statusMessage {
    switch (status) {
      case JobStatusType.processing:
        return 'Processing... ($completed/$total completed)';
      case JobStatusType.completed:
        return 'Completed successfully!';
      case JobStatusType.error:
        return error ?? 'An error occurred';
    }
  }

  @override
  List<Object?> get props => [
        id,
        status,
        progress,
        total,
        completed,
        results,
        error,
      ];
}

enum JobStatusType {
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('error')
  error,
}

extension JobStatusTypeExtension on JobStatusType {
  String get displayName {
    switch (this) {
      case JobStatusType.processing:
        return 'Processing';
      case JobStatusType.completed:
        return 'Completed';
      case JobStatusType.error:
        return 'Error';
    }
  }

  bool get isTerminal {
    return this == JobStatusType.completed || this == JobStatusType.error;
  }
}
