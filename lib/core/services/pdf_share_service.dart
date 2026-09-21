import 'dart:typed_data';

import 'package:flutter/services.dart';

class PdfShareService {
  static const MethodChannel _channel = MethodChannel('brivora/pdf_share');

  static Future<void> shareToApp({
    required String target,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _channel.invokeMethod<void>('sharePdfToApp', {
      'target': target,
      'fileName': fileName,
      'bytes': bytes,
    });
  }
}
