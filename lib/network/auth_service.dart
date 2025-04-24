import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String tokenUrl = "https://test.salesforce.com/services/oauth2/token";
  static const String baseURL = "https://cloudcentric--qb.sandbox.my.salesforce.com/services/apexrest/ValidateCredentials";
  static const String clientId = "3MVG9C63IhCOd.9FvdRGPk8SZdfeY7U7aBHcXKjJXC7M8ski1kb0MYu8CaKQ6SIaN_Xa4cF4JbDzGeX.kNq.x";
  static const String clientSecret = "B18E406773B575B7AB16CD58A48237376A8992165652A16849C1CB092E596ECA";
  static const String username = "shivamsharma@cccinfotech.com";
  static const String password = "Cloud@2025";

  final  storageService = GetStorage();

  Future<String?> fetchToken() async {
    try {
      var response = await http.post(
        Uri.parse(tokenUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "grant_type": "password",
          "client_id": clientId,
          "client_secret": clientSecret,
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final localStorage = GetStorage();

        var data = jsonDecode(response.body);
        String token = data['access_token'];
        localStorage.write("Access_token",token);
        print("Access_Token: ${data['access_token']}");
        return data['access_token']; // Return the token
      } else {
        print("Error fetching token: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      var response = await http.post(
        Uri.parse(baseURL),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "Username": username,
          "Password": password,
        },
      );

      if (response.statusCode == 200) {
        final localStorage = GetStorage();

        var data = jsonDecode(response.body);
        String token = data['access_token'];
        localStorage.write("Access_token",token);
        print("Token Received: ${data['access_token']}");
        return data['access_token']; // Return the token
      } else {
        print("Error fetching token: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
