// lib/data/repositories/pdf_repository_impl.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:megapdf_client/data/services/storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/pdf_api_service.dart';
import '../services/file_service.dart';
import 'pdf_repository.dart';

part 'pdf_repository_impl.g.dart';

@riverpod
PdfRepository pdfRepository(Ref ref) {
  final apiService = ref.watch(pdfApiServiceProvider);
  final fileService = ref.watch(fileServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return PdfRepositoryImpl(apiService, fileService, storageService);
}

class PdfRepositoryImpl implements PdfRepository {
  final PdfApiService _apiService;
  final FileService _fileService;
  final StorageService _storageService;

  PdfRepositoryImpl(this._apiService, this._fileService, this._storageService);

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
  Future<String> saveProcessedFile({
    required String fileUrl,
    required String filename,
    String? customFileName,
    String? subfolder,
  }) async {
    // First, download the file to the app's temporary storage
    final tempFilePath = await _fileService.saveFileToLocal(
      fileUrl: fileUrl,
      filename: filename,
      customFileName: customFileName,
    );

    // Then save it to the public storage with the appropriate subfolder
    final finalFilePath = await _storageService.saveFile(
      sourceFilePath: tempFilePath,
      fileName: customFileName ?? filename,
      addTimestamp: true,
    );

    if (finalFilePath != null) {
      // Delete the temporary file as we've now saved it to public storage
      try {
        final tempFile = File(tempFilePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        print('Error deleting temporary file: $e');
        // Continue even if temp file deletion fails
      }

      return finalFilePath;
    } else {
      // If saving to public storage failed, return the app's private storage path
      return tempFilePath;
    }
  }

}
