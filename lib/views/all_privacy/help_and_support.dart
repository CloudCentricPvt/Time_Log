import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class HelpAndSupport extends StatefulWidget {
  const HelpAndSupport({Key? key}) : super(key: key);

  @override
  State<HelpAndSupport> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<HelpAndSupport> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  WebViewController? controller;
  final String url = "https://forms.office.com/Pages/ResponsePage.aspx?id=zgMjasLRy06A5n3TvMEIS_Dxa13QO_FAjFrf9y3qLMhURDNKU1pTMDdMRU1BWjRRSDk1Q1ZPTVRYWi4u&origin=Invitation&channel=0&wdLOR=cBD637C3C-F7DC-9743-904A-7626DE1D191A";
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _initializeWebView() async {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isControllerReady = true);
            }
          },
        ),
      );

    await controller!.loadRequest(Uri.parse(url));
  }

  void _checkInternetConnection() async {
    bool connected = await _checkInternet.isConnected();
    if (!connected) {
      KMaterialDialogs.noInternetFound(
        context,
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
          },
          text: 'Okay',
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return;
    }
    _initializeWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(
          screenTitle: 'Help & Support',
          showHistory: false,
        ),
      ),
      body: _isControllerReady && controller != null
          ? WebViewWidget(controller: controller!)
          : const SizedBox.shrink(), // Nothing visible while loading
    );
  }
}
