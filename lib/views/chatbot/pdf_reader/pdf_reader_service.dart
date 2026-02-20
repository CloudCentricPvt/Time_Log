import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfReaderService {
  static Future<String> readPdfFromAssets(String path) async {
    final data = await rootBundle.load(path);
    final document = PdfDocument(inputBytes: data.buffer.asUint8List());

    final text = PdfTextExtractor(document).extractText();
    document.dispose();

    return text;
  }
}
