import 'package:time_log/views/chatbot/pdf_reader/pdf_reader_service.dart';

class CompanyPolicyLoader {
  static String _policyText = '';

  static Future<void> load() async {
    _policyText = await PdfReaderService.readPdfFromAssets(
      'assets/policies/company_policy.pdf',
    );
  }

  static String get policyText => _policyText;
}
