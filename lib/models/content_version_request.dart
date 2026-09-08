import 'dart:convert';

class ContentVersionRequest {
  final String title;
  final String pathOnClient;
  final String versionData; // Base64 encoded file data
  final String firstPublishLocationId; // Expense ID

  ContentVersionRequest({
    required this.title,
    required this.pathOnClient,
    required this.versionData,
    required this.firstPublishLocationId,
  });

  Map<String, dynamic> toJson() => {
    "Title": title,
    "PathOnClient": pathOnClient,
    "VersionData": versionData,
    "FirstPublishLocationId": firstPublishLocationId,
  };
}

class ContentVersionResponse {
  final String? id;
  final bool success;
  final List<dynamic>? errors;

  ContentVersionResponse({
    this.id,
    required this.success,
    this.errors,
  });

  factory ContentVersionResponse.fromJson(Map<String, dynamic> json) {
    return ContentVersionResponse(
      id: json['id'],
      success: json['success'] ?? false,
      errors: json['errors'],
    );
  }
}