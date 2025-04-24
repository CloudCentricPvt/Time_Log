
import 'package:http/http.dart' as http;
import 'dart:convert';

LoginResponse loginReqFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginReqToJson(LoginResponse data) => json.encode(data.toJson());

// Method to log in using API
Future<Map<String, dynamic>> login(var body, String apiUrl) async {

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return response body as a map
    } else {
      return {
        'success': false,
        'message': 'Login failed with status code ${response.statusCode}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'An error occurred: $e',
    };
  }
}

class LoginResponse {
  List<User>? users;
  bool? status;
  String? message;
  int? code;
  String? apiVersion;
  String? apiUrl;

  LoginResponse({
    this.users,
    this.status,
    this.message,
    this.code,
    this.apiVersion,
    this.apiUrl,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    users: json["users"] == null ? [] : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
    status: json["status"],
    message: json["message"],
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class User {
  Attributes? attributes;
  String? id;
  String? name;
  String? userNameC;
  String? passwordC;
  bool? isActiveC;

  User({
    this.attributes,
    this.id,
    this.name,
    this.userNameC,
    this.passwordC,
    this.isActiveC,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    attributes: json["attributes"] == null ? null : Attributes.fromJson(json["attributes"]),
    id: json["Id"],
    name: json["Name"],
    userNameC: json["User_Name__c"],
    passwordC: json["Password__c"],
    isActiveC: json["Is_Active__c"],
  );

  Map<String, dynamic> toJson() => {
    "attributes": attributes?.toJson(),
    "Id": id,
    "Name": name,
    "User_Name__c": userNameC,
    "Password__c": passwordC,
    "Is_Active__c": isActiveC,
  };
}

class Attributes {
  String? type;
  String? url;

  Attributes({
    this.type,
    this.url,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    type: json["type"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "url": url,
  };
}
