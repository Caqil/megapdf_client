import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'api_response.dart';

part 'convert_result.g.dart';

@JsonSerializable()
class ConvertResult extends Equatable {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? filename;
  final String? originalName;
  final String? inputFormat;
  final String? outputFormat;
  final BillingInfo? billing;

  const ConvertResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.filename,
    this.originalName,
    this.inputFormat,
    this.outputFormat,
    this.billing,
  });

  factory ConvertResult.fromJson(Map<String, dynamic> json) =>
      _$ConvertResultFromJson(json);

  Map<String, dynamic> toJson() => _$ConvertResultToJson(this);

  // Convenience getters
  String get conversionSummary {
    if (inputFormat == null || outputFormat == null) {
      return 'File converted successfully';
    }
    return '${inputFormat!.toUpperCase()} → ${outputFormat!.toUpperCase()}';
  }

  @override
  List<Object?> get props => [
        success,
        message,
        fileUrl,
        filename,
        originalName,
        inputFormat,
        outputFormat,
        billing,
      ];
}

// Conversion options model for requests
@JsonSerializable()
class ConvertOptions extends Equatable {
  final String inputFormat;
  final String outputFormat;
  final bool? ocr;
  final int? quality;
  final String? password;

  const ConvertOptions({
    required this.inputFormat,
    required this.outputFormat,
    this.ocr = false,
    this.quality = 90,
    this.password,
  });

  factory ConvertOptions.fromJson(Map<String, dynamic> json) =>
      _$ConvertOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$ConvertOptionsToJson(this);

  @override
  List<Object?> get props => [
        inputFormat,
        outputFormat,
        ocr,
        quality,
        password,
      ];
}

// Supported formats enum
enum FileFormat {
  @JsonValue('pdf')
  pdf,
  @JsonValue('docx')
  docx,
  @JsonValue('doc')
  doc,
  @JsonValue('xlsx')
  xlsx,
  @JsonValue('xls')
  xls,
  @JsonValue('pptx')
  pptx,
  @JsonValue('rtf')
  rtf,
  @JsonValue('txt')
  txt,
  @JsonValue('html')
  html,
  @JsonValue('jpg')
  jpg,
  @JsonValue('jpeg')
  jpeg,
  @JsonValue('png')
  png,
  @JsonValue('gif')
  gif,
}

extension FileFormatExtension on FileFormat {
  String get displayName {
    switch (this) {
      case FileFormat.pdf:
        return 'PDF';
      case FileFormat.docx:
        return 'Word Document (DOCX)';
      case FileFormat.doc:
        return 'Word Document (DOC)';
      case FileFormat.xlsx:
        return 'Excel Spreadsheet (XLSX)';
      case FileFormat.xls:
        return 'Excel Spreadsheet (XLS)';
      case FileFormat.pptx:
        return 'PowerPoint Presentation (PPTX)';
      case FileFormat.rtf:
        return 'Rich Text Format (RTF)';
      case FileFormat.txt:
        return 'Text File (TXT)';
      case FileFormat.html:
        return 'HTML Document';
      case FileFormat.jpg:
      case FileFormat.jpeg:
        return 'JPEG Image';
      case FileFormat.png:
        return 'PNG Image';
      case FileFormat.gif:
        return 'GIF Image';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  bool get isImageFormat {
    return [FileFormat.jpg, FileFormat.jpeg, FileFormat.png, FileFormat.gif]
        .contains(this);
  }

  bool get isDocumentFormat {
    return [
      FileFormat.pdf,
      FileFormat.docx,
      FileFormat.doc,
      FileFormat.xlsx,
      FileFormat.xls,
      FileFormat.pptx,
      FileFormat.rtf,
      FileFormat.txt,
      FileFormat.html,
    ].contains(this);
  }
}
