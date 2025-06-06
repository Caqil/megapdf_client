// lib/data/repositories/pdf_repository.dart
import 'dart:io';
import '../models/compress_result.dart';
import '../models/split_result.dart';
import '../models/merge_result.dart';
import '../models/watermark_result.dart';
import '../models/convert_result.dart';
import '../models/protect_result.dart';
import '../models/unlock_result.dart';
import '../models/rotate_result.dart';
import '../models/job_status.dart';
import '../models/split_options.dart';

abstract class PdfRepository {
  // Compress PDF
  Future<CompressResult> compressPdf(File file);

  // Split PDF
  Future<SplitResult> splitPdf(File file, SplitOptions options);
  Future<JobStatus> getSplitJobStatus(String jobId);

  // Merge PDFs
  Future<MergeResult> mergePdfs(List<File> files, {List<int>? order});

  // Watermark PDF
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
  });

  Future<WatermarkResult> addImageWatermark(
    File file,
    File imageFile, {
    String? position,
    String? watermarkType,
    int? rotation,
    int? opacity,
    int? scale,
    String? pages,
    String? customPages,
    int? customX,
    int? customY,
  });

  // Convert PDF
  Future<ConvertResult> convertFile(
    File file,
    String inputFormat,
    String outputFormat, {
    bool? enableOcr,
    int? quality,
    String? password,
  });

  // Protect PDF
  Future<ProtectResult> protectPdf(
    File file,
    String password, {
    String? permission,
    bool? allowPrinting,
    bool? allowCopying,
    bool? allowEditing,
  });

  // Unlock PDF
  Future<UnlockResult> unlockPdf(File file, String password);

  // Rotate PDF
  Future<RotateResult> rotatePdf(
    File file,
    int angle, {
    String? pages,
  });

  // Add page numbers
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
  });

  // File operations
  Future<String> saveProcessedFile({
    required String fileUrl,
    required String filename,
    String? customFileName,
    String? subfolder,
  });
}
