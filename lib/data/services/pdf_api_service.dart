import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/data/models/pdf_file.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/dio_config.dart';
import '../../core/constants/api_constants.dart';
import '../models/compress_result.dart';
import '../models/split_result.dart';
import '../models/merge_result.dart';
import '../models/watermark_result.dart';
import '../models/convert_result.dart';
import '../models/protect_result.dart';
import '../models/unlock_result.dart';
import '../models/rotate_result.dart';
import '../models/job_status.dart';

part 'pdf_api_service.g.dart';

@riverpod
PdfApiService pdfApiService(Ref ref) {
  final dio = ref.watch(multipartDioProvider);
  return PdfApiService(dio);
}

@RestApi()
abstract class PdfApiService {
  factory PdfApiService(Dio dio) = _PdfApiService;

  // Compress PDF
  @POST(ApiConstants.compressPdf)
  @MultiPart()
  Future<CompressResult> compressPdf(
    @Part(name: 'file') File file,
  );

  // Split PDF
  @POST(ApiConstants.splitPdf)
  @MultiPart()
  Future<SplitResult> splitPdf(
    @Part(name: 'file') File file,
    @Part(name: 'splitMethod') String splitMethod,
    @Part(name: 'pageRanges') String? pageRanges,
    @Part(name: 'everyNPages') int? everyNPages,
  );

  // Get split job status
  @GET(ApiConstants.splitStatus)
  Future<JobStatus> getSplitStatus(
    @Query('id') String jobId,
  );

  // Merge PDFs
  @POST(ApiConstants.mergePdf)
  @MultiPart()
  Future<MergeResult> mergePdfs(
    @Part(name: 'files') List<File> files,
    @Part(name: 'order') String? order,
  );

  // Add watermark to PDF
  @POST(ApiConstants.watermarkPdf)
  @MultiPart()
  Future<WatermarkResult> watermarkPdf(
    @Part(name: 'file') File file,
    @Part(name: 'watermarkType') String watermarkType,
    // Text watermark options
    @Part(name: 'text') String? text,
    @Part(name: 'textColor') String? textColor,
    @Part(name: 'fontSize') int? fontSize,
    @Part(name: 'fontFamily') String? fontFamily,
    // Image watermark options
    @Part(name: 'watermarkImage') File? watermarkImage,
    @Part(name: 'content') String? content, // For base64 image
    // Common options
    @Part(name: 'position') String? position,
    @Part(name: 'rotation') int? rotation,
    @Part(name: 'opacity') int? opacity,
    @Part(name: 'scale') int? scale,
    @Part(name: 'pages') String? pages,
    @Part(name: 'customPages') String? customPages,
    @Part(name: 'customX') int? customX,
    @Part(name: 'customY') int? customY,
    @Part(name: 'description') String? description,
  );

  // Convert PDF
  @POST(ApiConstants.convertPdf)
  @MultiPart()
  Future<ConvertResult> convertPdf(
    @Part(name: 'file') File file,
    @Part(name: 'inputFormat') String inputFormat,
    @Part(name: 'outputFormat') String outputFormat,
    @Part(name: 'ocr') bool? ocr,
    @Part(name: 'quality') int? quality,
    @Part(name: 'password') String? password,
  );

  // Protect PDF
  @POST(ApiConstants.protectPdf)
  @MultiPart()
  Future<ProtectResult> protectPdf(
    @Part(name: 'file') File file,
    @Part(name: 'password') String password,
    @Part(name: 'permission') String? permission,
    @Part(name: 'allowPrinting') bool? allowPrinting,
    @Part(name: 'allowCopying') bool? allowCopying,
    @Part(name: 'allowEditing') bool? allowEditing,
  );

  // Unlock PDF
  @POST(ApiConstants.unlockPdf)
  @MultiPart()
  Future<UnlockResult> unlockPdf(
    @Part(name: 'file') File file,
    @Part(name: 'password') String password,
  );

  // Rotate PDF
  @POST(ApiConstants.rotatePdf)
  @MultiPart()
  Future<RotateResult> rotatePdf(
    @Part(name: 'file') File file,
    @Part(name: 'angle') int angle,
    @Part(name: 'pages') String? pages,
  );

  // Add page numbers to PDF
  @POST(ApiConstants.addPageNumbers)
  @MultiPart()
  Future<PageNumbersResult> addPageNumbers(
    @Part(name: 'file') File file,
    @Part(name: 'position') String? position,
    @Part(name: 'format') String? format,
    @Part(name: 'fontFamily') String? fontFamily,
    @Part(name: 'fontSize') int? fontSize,
    @Part(name: 'color') String? color,
    @Part(name: 'startNumber') int? startNumber,
    @Part(name: 'prefix') String? prefix,
    @Part(name: 'suffix') String? suffix,
    @Part(name: 'marginX') int? marginX,
    @Part(name: 'marginY') int? marginY,
    @Part(name: 'selectedPages') String? selectedPages,
    @Part(name: 'skipFirstPage') bool? skipFirstPage,
  );

  // Download processed file
  @GET(ApiConstants.serveFile)
  Future<FileDownloadResult> downloadFile(
    @Query('folder') String folder,
    @Query('filename') String filename,
  );
}
