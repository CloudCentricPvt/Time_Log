import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class CheckInternetAvailable{
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // Check if device is connected to mobile or wifi
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // Try pinging a real website to confirm internet access
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

}