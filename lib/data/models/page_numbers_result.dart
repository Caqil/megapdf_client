// Page numbering options model for requests
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_numbers_result.g.dart';

@JsonSerializable()
class PageNumberingOptions extends Equatable {
  final String position;
  final String format;
  final String fontFamily;
  final int fontSize;
  final String color;
  final int startNumber;
  final String prefix;
  final String suffix;
  final int marginX;
  final int marginY;
  final String selectedPages;
  final bool skipFirstPage;

  const PageNumberingOptions({
    this.position = 'bottom-center',
    this.format = 'numeric',
    this.fontFamily = 'Helvetica',
    this.fontSize = 12,
    this.color = '#000000',
    this.startNumber = 1,
    this.prefix = '',
    this.suffix = '',
    this.marginX = 40,
    this.marginY = 30,
    this.selectedPages = '',
    this.skipFirstPage = false,
  });

  factory PageNumberingOptions.fromJson(Map<String, dynamic> json) =>
      _$PageNumberingOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$PageNumberingOptionsToJson(this);

  @override
  List<Object?> get props => [
        position,
        format,
        fontFamily,
        fontSize,
        color,
        startNumber,
        prefix,
        suffix,
        marginX,
        marginY,
        selectedPages,
        skipFirstPage,
      ];
}

enum NumberingPosition {
  @JsonValue('top-left')
  topLeft,
  @JsonValue('top-center')
  topCenter,
  @JsonValue('top-right')
  topRight,
  @JsonValue('bottom-left')
  bottomLeft,
  @JsonValue('bottom-center')
  bottomCenter,
  @JsonValue('bottom-right')
  bottomRight,
}

enum NumberingFormat {
  @JsonValue('numeric')
  numeric,
  @JsonValue('roman')
  roman,
  @JsonValue('alphabetic')
  alphabetic,
}

extension NumberingPositionExtension on NumberingPosition {
  String get displayName {
    switch (this) {
      case NumberingPosition.topLeft:
        return 'Top Left';
      case NumberingPosition.topCenter:
        return 'Top Center';
      case NumberingPosition.topRight:
        return 'Top Right';
      case NumberingPosition.bottomLeft:
        return 'Bottom Left';
      case NumberingPosition.bottomCenter:
        return 'Bottom Center';
      case NumberingPosition.bottomRight:
        return 'Bottom Right';
    }
  }

  String get value {
    return toString().split('.').last.replaceAll('_', '-');
  }
}

extension NumberingFormatExtension on NumberingFormat {
  String get displayName {
    switch (this) {
      case NumberingFormat.numeric:
        return 'Numbers (1, 2, 3...)';
      case NumberingFormat.roman:
        return 'Roman (I, II, III...)';
      case NumberingFormat.alphabetic:
        return 'Letters (A, B, C...)';
    }
  }

  String get value {
    return toString().split('.').last;
  }
}
