// lib/data/repositories/pdf_repository_impl.dart
import 'dart:io';

import 'package:megapdf_client/data/models/compress_result.dart';
import 'package:megapdf_client/data/models/convert_result.dart';
import 'package:megapdf_client/data/models/job_status.dart';
import 'package:megapdf_client/data/models/merge_result.dart';
import 'package:megapdf_client/data/models/protect_result.dart';
import 'package:megapdf_client/data/models/rotate_result.dart';
import 'package:megapdf_client/data/models/split_options.dart';
import 'package:megapdf_client/data/models/split_result.dart';
import 'package:megapdf_client/data/models/unlock_result.dart';
import 'package:megapdf_client/data/models/watermark_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/pdf_api_service.dart';
import '../services/file_service.dart';
import 'pdf_repository.dart';

part 'pdf_repository_impl.g.dart';

@riverpod
PdfRepository pdfRepository(PdfRepositoryRef ref) {
  final apiService = ref.watch(pdfApiServiceProvider);
  final fileService = ref.watch(fileServiceProvider);
  return PdfRepositoryImpl(apiService, fileService);
}

class PdfRepositoryImpl implements PdfRepository {
  final PdfApiService _apiService;
  final FileService _fileService;

  PdfRepositoryImpl(this._apiService, this._fileService);

  @override
  Future<CompressResult> compressPdf(File file) async {
    return await _apiService.compressPdf(file);
  }

  @override
  Future<SplitResult> splitPdf(File file, SplitOptions options) async {
    return await _apiService.splitPdf(
      file,
      options.splitMethod.value,
      options.pageRanges,
      options.everyNPages,
    );
  }

  @override
  Future<JobStatus> getSplitJobStatus(String jobId) async {
    return await _apiService.getSplitStatus(jobId);
  }

  @override
  Future<MergeResult> mergePdfs(List<File> files, {List<int>? order}) async {
    String? orderJson;
    if (order != null && order.isNotEmpty) {
      orderJson = order.join(',');
    }
    return await _apiService.mergePdfs(files, orderJson);
  }

  @override
  Future<WatermarkResult> addTextWatermark(
    File file,
    String text, {
    String? textColor,
    int? fontSize,
    String? fontFamily,
    String? position,
    int? rotation,
    int? opacity,
    String? pages,
    String? customPages,
    int? customX,
    int? customY,
  }) async {
    return await _apiService.watermarkPdf(
      file,
      'text',
      text,
      textColor,
      fontSize,
      fontFamily,
      null, // watermarkImage
      null, // content
      position,
      rotation,
      opacity,
      null, // scale
      pages,
      customPages,
      customX,
      customY,
      null, // description
    );
  }

  @override
  Future<WatermarkResult> addImageWatermark(
    File file,
    File imageFile, {
    String? position,
    int? rotation,
    int? opacity,
    int? scale,
    String? pages,
    String? customPages,
    int? customX,
    int? customY,
  }) async {
    return await _apiService.watermarkPdf(
      file,
      'image',
      null, // text
      null, // textColor
      null, // fontSize
      null, // fontFamily
      imageFile,
      null, // content
      position,
      rotation,
      opacity,
      scale,
      pages,
      customPages,
      customX,
      customY,
      null, // description
    );
  }

  @override
  Future<ConvertResult> convertFile(
    File file,
    String inputFormat,
    String outputFormat, {
    bool? enableOcr,
    int? quality,
    String? password,
  }) async {
    return await _apiService.convertPdf(
      file,
      inputFormat,
      outputFormat,
      enableOcr,
      quality,
      password,
    );
  }

  @override
  Future<ProtectResult> protectPdf(
    File file,
    String password, {
    String? permission,
    bool? allowPrinting,
    bool? allowCopying,
    bool? allowEditing,
  }) async {
    return await _apiService.protectPdf(
      file,
      password,
      permission,
      allowPrinting,
      allowCopying,
      allowEditing,
    );
  }

  @override
  Future<UnlockResult> unlockPdf(File file, String password) async {
    return await _apiService.unlockPdf(file, password);
  }

  @override
  Future<RotateResult> rotatePdf(
    File file,
    int angle, {
    String? pages,
  }) async {
    return await _apiService.rotatePdf(file, angle, pages);
  }

  @override
  Future<PageNumbersResult> addPageNumbers(
    File file, {
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
  }) async {
    return await _apiService.addPageNumbers(
      file,
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
    );
  }

  @override
  Future<String> downloadFile({
    required String folder,
    required String filename,
    String? customFileName,
    Function(double progress)? onProgress,
  }) async {
    return await _fileService.downloadAndSaveFile(
      folder: folder,
      filename: filename,
      customFileName: customFileName,
      onProgress: onProgress,
    );
  }
}
