class ApiConstants {
  // Base Configuration
  static const String baseUrl = 'https://api.mega-pdf.com';
  static const String apiKey =
      'sk_d6c1daa54dbc95956b281fa02c544e7273ed10df60b211fe';

  // API Endpoints
  static const String _apiPrefix = '/api';

  // PDF Operations
  static const String compressPdf = '$_apiPrefix/pdf/compress';
  static const String splitPdf = '$_apiPrefix/pdf/split';
  static const String splitStatus = '$_apiPrefix/pdf/split/status';
  static const String mergePdf = '$_apiPrefix/pdf/merge';
  static const String watermarkPdf = '$_apiPrefix/pdf/watermark';
  static const String convertPdf = '$_apiPrefix/pdf/convert';
  static const String protectPdf = '$_apiPrefix/pdf/protect';
  static const String unlockPdf = '$_apiPrefix/pdf/unlock';
  static const String rotatePdf = '$_apiPrefix/pdf/rotate';
  static const String addPageNumbers = '$_apiPrefix/pdf/pagenumber';

  // File serving
  static const String serveFile = '$_apiPrefix/file';

  // Request Configuration
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 120000; // 2 minutes for large files
  static const int sendTimeout = 120000; // 2 minutes for uploads

  // File Limits
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> supportedFormats = [
    'pdf',
    'docx',
    'xlsx',
    'pptx',
    'txt',
    'html',
    'rtf',
    'jpg',
    'jpeg',
    'png',
    'gif'
  ];

  // Headers
  static const String apiKeyHeader = 'x-api-key';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';

  // Response Status
  static const int successCode = 200;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int paymentRequiredCode = 402;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;
}
