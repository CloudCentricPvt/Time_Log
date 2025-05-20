import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/privacy_policy_res.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class PrivacyPoliciesScreen extends StatefulWidget {
  const PrivacyPoliciesScreen({super.key});

  @override
  State<PrivacyPoliciesScreen> createState() => _PrivacyPoliciesScreenState();
}

class _PrivacyPoliciesScreenState extends State<PrivacyPoliciesScreen> {
  bool _isLoading = false;
  String? localPath;
  String? policyURL;
  String? localPdfPath;
  final storage = GetStorage();
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    fetchPrivacyPolicy();


  }

  Future<void> loadPdf() async {
    final String contentVersionId = '068XXXXXXXXXXXX'; // <-- actual ContentVersionId
    final String pdfUrl = 'https://cloudcentric--qb.sandbox.my.salesforce.com/services/data/v58.0/sobjects/ContentVersion/$contentVersionId/VersionData';
    //final String pdfUrl = 'https://cloudcentric--qb.sandbox.my.salesforce.com/sfc/p/7z000009XoH0/a/7z000001EcRR/tA1Ke2KYpiwIYbyizxQkbby2aQVNujSF6COLkF_I9Ug';
    //final String pdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';



    final response = await http.get(
      Uri.parse(pdfUrl),
      headers: {
        'Authorization': 'Bearer ${storage.read('Access_token')}',
      },
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(bytes);
      setState(() {
        localPdfPath = file.path;
      });
    } else {
      // Handle error
      print('Failed to download PDF: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(screenTitle: 'Privacy Policy'),
      ),
      body: WebViewWidget(controller: _webViewController),
      /*body: WebView(
        initialUrl: policyURL,
        javascriptMode: JavascriptMode.unrestricted,  // Enable JavaScript
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        onPageStarted: (url) {
          print('Page started loading: $url');
        },
        onPageFinished: (url) {
          print('Page finished loading: $url');
        },
      ),*/
    );
  }

  Future<void> fetchPrivacyPolicy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await privacyPolicy(context); // Assuming this returns PrivacyPolicyResponse
      print('Response: $res'); // Debug print

      if (res is PrivacyPolicyResponse) {
        // Access the policyUrl from the first Policy object in the list
        if (res.policy.isNotEmpty) {
          policyURL = res.policy[0].policyUrl;
          print('Policy URL: $policyURL');
          // Once the URL is fetched, call the method to download the PDF
          await loadPdf();
        } else {
          print('No policy URL found.');
        }
      } else {
        print('Failed to fetch policy data.');
      }
    } catch (e) {
      print('Error fetching policy: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

}
