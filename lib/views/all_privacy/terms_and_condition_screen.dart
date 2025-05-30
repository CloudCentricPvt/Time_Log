
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/privacy_policy_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';


class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionScreen> createState() => _TermsAndConditionScreen();
}

class _TermsAndConditionScreen extends State<TermsAndConditionScreen> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  WebViewController? controller;
  bool _isLoading = false;
  bool _isControllerReady = false;
  String policyURL = '';


  @override
  void initState() {
    super.initState();

    _checkInternetConnection();

  }

  Future<void> _initializeWebView() async {
    // No need to set the platform explicitly
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      );

    await controller?.loadRequest(Uri.parse(policyURL));
    setState(() {
      _isControllerReady = true;
    });

  }

  Future<void> fetchTermsAndCondition() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await termsAndCondition(context); // Assuming this returns PrivacyPolicyResponse
      print('Response: $res'); // Debug print

      if (res is PrivacyPolicyResponse) {
        // Access the policyUrl from the first Policy object in the list
        if (res.policy.isNotEmpty) {
          policyURL = res.policy[0].policyUrl;
          _initializeWebView();

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

  void _checkInternetConnection() async {
    bool connected = await _checkInternet.isConnected();
    if (!connected) {
      // Show no internet dialog or handle no connectivity case
      KMaterialDialogs.noInternetFound(
        context,
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
            // Maybe retry or do something else
          },
          text: 'Okay',
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return; // Stop further API calls
    }
    fetchTermsAndCondition();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(screenTitle: 'Terms and Conditions'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF), // Same as app bar
          statusBarIconBrightness: Brightness.dark, // or .light depending on contrast
        ),
      ),
      body: _isLoading? KLoader(): Stack(
        children: [
          if (_isControllerReady && controller != null)
            WebViewWidget(controller: controller!)
          else
            const Center(child: Text("Loading...")),
        ],
      ),

    );
  }
}


