// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _PdfApiService implements PdfApiService {
  _PdfApiService(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  });

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<CompressResult> compressPdf(File file) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    final _options = _setStreamType<CompressResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/compress',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CompressResult _value;
    try {
      _value = CompressResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SplitResult> splitPdf(
    File file,
    String splitMethod,
    String? pageRanges,
    int? everyNPages,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    _data.fields.add(MapEntry(
      'splitMethod',
      splitMethod,
    ));
    if (pageRanges != null) {
      _data.fields.add(MapEntry(
        'pageRanges',
        pageRanges,
      ));
    }
    if (everyNPages != null) {
      _data.fields.add(MapEntry(
        'everyNPages',
        everyNPages.toString(),
      ));
    }
    final _options = _setStreamType<SplitResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/split',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SplitResult _value;
    try {
      _value = SplitResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<JobStatus> getSplitStatus(String jobId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'id': jobId};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<JobStatus>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/pdf/split/status',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late JobStatus _value;
    try {
      _value = JobStatus.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<MergeResult> mergePdfs(
    List<File> files,
    String? order,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.addAll(files.map((i) => MapEntry(
        'files',
        MultipartFile.fromFileSync(
          i.path,
          filename: i.path.split(Platform.pathSeparator).last,
        ))));
    if (order != null) {
      _data.fields.add(MapEntry(
        'order',
        order,
      ));
    }
    final _options = _setStreamType<MergeResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/merge',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late MergeResult _value;
    try {
      _value = MergeResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<WatermarkResult> watermarkPdf(
    File file,
    String watermarkType,
    String? text,
    String? textColor,
    int? fontSize,
    String? fontFamily,
    File? watermarkImage,
    String? content,
    String? position,
    int? rotation,
    int? opacity,
    int? scale,
    String? pages,
    String? customPages,
    int? customX,
    int? customY,
    String? description,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    _data.fields.add(MapEntry(
      'watermarkType',
      watermarkType,
    ));
    if (text != null) {
      _data.fields.add(MapEntry(
        'text',
        text,
      ));
    }
    if (textColor != null) {
      _data.fields.add(MapEntry(
        'textColor',
        textColor,
      ));
    }
    if (fontSize != null) {
      _data.fields.add(MapEntry(
        'fontSize',
        fontSize.toString(),
      ));
    }
    if (fontFamily != null) {
      _data.fields.add(MapEntry(
        'fontFamily',
        fontFamily,
      ));
    }
    _data.files.add(MapEntry(
      'watermarkImage',
      MultipartFile.fromFileSync(
        watermarkImage!.path,
        filename: watermarkImage.path.split(Platform.pathSeparator).last,
      ),
    ));
    if (content != null) {
      _data.fields.add(MapEntry(
        'content',
        content,
      ));
    }
    if (position != null) {
      _data.fields.add(MapEntry(
        'position',
        position,
      ));
    }
    if (rotation != null) {
      _data.fields.add(MapEntry(
        'rotation',
        rotation.toString(),
      ));
    }
    if (opacity != null) {
      _data.fields.add(MapEntry(
        'opacity',
        opacity.toString(),
      ));
    }
    if (scale != null) {
      _data.fields.add(MapEntry(
        'scale',
        scale.toString(),
      ));
    }
    if (pages != null) {
      _data.fields.add(MapEntry(
        'pages',
        pages,
      ));
    }
    if (customPages != null) {
      _data.fields.add(MapEntry(
        'customPages',
        customPages,
      ));
    }
    if (customX != null) {
      _data.fields.add(MapEntry(
        'customX',
        customX.toString(),
      ));
    }
    if (customY != null) {
      _data.fields.add(MapEntry(
        'customY',
        customY.toString(),
      ));
    }
    if (description != null) {
      _data.fields.add(MapEntry(
        'description',
        description,
      ));
    }
    final _options = _setStreamType<WatermarkResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/watermark',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late WatermarkResult _value;
    try {
      _value = WatermarkResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ConvertResult> convertPdf(
    File file,
    String inputFormat,
    String outputFormat,
    bool? ocr,
    int? quality,
    String? password,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    _data.fields.add(MapEntry(
      'inputFormat',
      inputFormat,
    ));
    _data.fields.add(MapEntry(
      'outputFormat',
      outputFormat,
    ));
    if (ocr != null) {
      _data.fields.add(MapEntry(
        'ocr',
        ocr.toString(),
      ));
    }
    if (quality != null) {
      _data.fields.add(MapEntry(
        'quality',
        quality.toString(),
      ));
    }
    if (password != null) {
      _data.fields.add(MapEntry(
        'password',
        password,
      ));
    }
    final _options = _setStreamType<ConvertResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/convert',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ConvertResult _value;
    try {
      _value = ConvertResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ProtectResult> protectPdf(
    File file,
    String password,
    String? permission,
    bool? allowPrinting,
    bool? allowCopying,
    bool? allowEditing,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    _data.fields.add(MapEntry(
      'password',
      password,
    ));
    if (permission != null) {
      _data.fields.add(MapEntry(
        'permission',
        permission,
      ));
    }
    if (allowPrinting != null) {
      _data.fields.add(MapEntry(
        'allowPrinting',
        allowPrinting.toString(),
      ));
    }
    if (allowCopying != null) {
      _data.fields.add(MapEntry(
        'allowCopying',
        allowCopying.toString(),
      ));
    }
    if (allowEditing != null) {
      _data.fields.add(MapEntry(
        'allowEditing',
        allowEditing.toString(),
      ));
    }
    final _options = _setStreamType<ProtectResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/protect',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProtectResult _value;
    try {
      _value = ProtectResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<UnlockResult> unlockPdf(
    File file,
    String password,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    _data.fields.add(MapEntry(
      'password',
      password,
    ));
    final _options = _setStreamType<UnlockResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/unlock',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UnlockResult _value;
    try {
      _value = UnlockResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<RotateResult> rotatePdf(
    File file,
    int angle,
    String? pages,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    _data.fields.add(MapEntry(
      'angle',
      angle.toString(),
    ));
    if (pages != null) {
      _data.fields.add(MapEntry(
        'pages',
        pages,
      ));
    }
    final _options = _setStreamType<RotateResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/rotate',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late RotateResult _value;
    try {
      _value = RotateResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PageNumbersResult> addPageNumbers(
    File file,
    String? position,
    String? format,
    String? fontFamily,
    int? fontSize,
    String? color,
    int? startNumber,
    String? prefix,
    String? suffix,
    int? marginX,
    int? marginY,
    String? selectedPages,
    bool? skipFirstPage,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry(
      'file',
      MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    ));
    if (position != null) {
      _data.fields.add(MapEntry(
        'position',
        position,
      ));
    }
    if (format != null) {
      _data.fields.add(MapEntry(
        'format',
        format,
      ));
    }
    if (fontFamily != null) {
      _data.fields.add(MapEntry(
        'fontFamily',
        fontFamily,
      ));
    }
    if (fontSize != null) {
      _data.fields.add(MapEntry(
        'fontSize',
        fontSize.toString(),
      ));
    }
    if (color != null) {
      _data.fields.add(MapEntry(
        'color',
        color,
      ));
    }
    if (startNumber != null) {
      _data.fields.add(MapEntry(
        'startNumber',
        startNumber.toString(),
      ));
    }
    if (prefix != null) {
      _data.fields.add(MapEntry(
        'prefix',
        prefix,
      ));
    }
    if (suffix != null) {
      _data.fields.add(MapEntry(
        'suffix',
        suffix,
      ));
    }
    if (marginX != null) {
      _data.fields.add(MapEntry(
        'marginX',
        marginX.toString(),
      ));
    }
    if (marginY != null) {
      _data.fields.add(MapEntry(
        'marginY',
        marginY.toString(),
      ));
    }
    if (selectedPages != null) {
      _data.fields.add(MapEntry(
        'selectedPages',
        selectedPages,
      ));
    }
    if (skipFirstPage != null) {
      _data.fields.add(MapEntry(
        'skipFirstPage',
        skipFirstPage.toString(),
      ));
    }
    final _options = _setStreamType<PageNumbersResult>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/api/pdf/add-page-numbers',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PageNumbersResult _value;
    try {
      _value = PageNumbersResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<FileDownloadResult> downloadFile(
    String folder,
    String filename,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'folder': folder,
      r'filename': filename,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FileDownloadResult>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/api/file',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FileDownloadResult _value;
    try {
      _value = FileDownloadResult.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfApiServiceHash() => r'fbcc5794d0fe4c16e42fca56dd7b716d0573ee60';

/// See also [pdfApiService].
@ProviderFor(pdfApiService)
final pdfApiServiceProvider = AutoDisposeProvider<PdfApiService>.internal(
  pdfApiService,
  name: r'pdfApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pdfApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PdfApiServiceRef = AutoDisposeProviderRef<PdfApiService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
