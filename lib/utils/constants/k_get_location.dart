import 'package:flutter/services.dart';

class KGetLocation {
  static const MethodChannel _channel =
  MethodChannel('com.example.time_log/location'); // Make sure this matches your Android Kotlin channel

  static Future<Map<String, double>?> getLocation() async {
    try {
      final result = await _channel.invokeMethod<Map>('getLocation');
      if (result != null) {
        return {
          'latitude': (result['latitude'] as double?) ?? 0.0,
          'longitude': (result['longitude'] as double?) ?? 0.0,
        };
      }
    } on PlatformException catch (e) {
      print("PlatformException: ${e.message}");
    }
    return null;
  }
}
