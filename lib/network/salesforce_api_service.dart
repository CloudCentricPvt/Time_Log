import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:time_log/utils/constants/api_container.dart';

import '../models/content_document_link_response.dart';
import '../models/content_version_response.dart';

/// Service class for interacting with Salesforce Standard APIs
class SalesforceAPIService {
  static final SalesforceAPIService _instance = SalesforceAPIService._internal();
  factory SalesforceAPIService() => _instance;
  SalesforceAPIService._internal();

  // ==========================================================================
  // CONFIGURATION
  // ==========================================================================

  /// Salesforce instance URL (should be stored securely)
  final storage = GetStorage();

  // ==========================================================================
  // AUTHENTICATION HELPERS
  // ==========================================================================

  /// Get headers with Bearer token
  Map<String, String> _getHeaders() {
    var accessToken = storage.read("Access_token") ?? "";
    var userId = storage.read("User_Id") ?? "";

    final headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
      //'auth_token': accessToken,
      //'user_code': userId.toString(),
      'Authorization': 'Bearer $accessToken',
    };

    return headers;
  }

  // ==========================================================================
  // QUERY API - GET
  // ==========================================================================
  Future<SalesforceQueryResponse> query(String soql) async {

    try {
      final encodedQuery = Uri.encodeQueryComponent(soql);
      final url = '${KApiEndPoints.baseUrl}data/v65.0/query?q=$encodedQuery';

      print('📡 Salesforce Query URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return SalesforceQueryResponse(
          totalSize: data['totalSize'] ?? 0,
          done: data['done'] ?? true,
          records: (data['records'] as List?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [],
          nextRecordsUrl: data['nextRecordsUrl'],
        );
      } else {
        throw Exception('Failed to query: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error in query: $e');
      rethrow;
    }
  }

  Future<SalesforceQueryResponse> queryRaw(String soql) async {

    try {
      final encodedQuery = Uri.encodeQueryComponent(soql);
      final url = '${KApiEndPoints.baseUrl}data/v65.0/query?q=$encodedQuery';

      print('📡 Salesforce Query URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return SalesforceQueryResponse.fromJson(data);
      } else {
        throw Exception('Failed to query: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error in query: $e');
      rethrow;
    }
  }

  /// Execute a SOQL query with automatic pagination
  /// This will fetch all records by following nextRecordsUrl
  Future<List<Map<String, dynamic>>> queryAll(String soql) async {
    final allRecords = <Map<String, dynamic>>[];
    String? nextUrl;

    try {
      var response = await query(soql);
      allRecords.addAll(response.records);

      // Follow pagination
      while (response.nextRecordsUrl != null) {
        debugPrint('Fetching next page...');
        response = await _fetchNextPage(response.nextRecordsUrl!);
        allRecords.addAll(response.records);
      }

      debugPrint('Fetched ${allRecords.length} records total');
      return allRecords;
    } catch (e) {
      debugPrint('Error fetching all records: $e');
      throw SalesforceException('Failed to fetch all records: $e');
    }
  }

  /// Fetch next page of results
  Future<SalesforceQueryResponse> _fetchNextPage(String nextUrl) async {

    try {
      final url = '${KApiEndPoints.baseUrl}$nextUrl';

      debugPrint('Fetching next page: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      return _handleResponse(response, 'nextPage');
    } catch (e) {
      debugPrint('Error fetching next page: $e');
      throw SalesforceException('Failed to fetch next page: $e');
    }
  }

  /// Fetches picklist values for a specific field on an SObject.
  /// Returns a list of labels (or values) as strings.
  Future<List<String>> getPicklistValuesUIAPI(
      String objectName,
      String fieldName, {
        String? recordTypeId, // Optional: if you need record-type specific picklist
        bool useLabel = true,
      })
  async {

    try {
      // Build URL for UI API
      String url;
      if (recordTypeId != null && recordTypeId.isNotEmpty) {
        // URL with record type
        url = '${KApiEndPoints.baseUrl}data/v65.0/ui-api/object-info/$objectName/picklist-values/$recordTypeId/$fieldName';
      } else {
        // URL without record type (uses default record type)
        url = '${KApiEndPoints.baseUrl}data/v65.0/ui-api/object-info/$objectName/picklist-values/012000000000000AAA/$fieldName';
      }

      debugPrint('📡 Fetching picklist from UI API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final values = data['values'] as List<dynamic>?;

        if (values == null || values.isEmpty) {
          return [];
        }

        // Extract labels or values based on parameter
        return values
            .map((v) => (useLabel ? v['label'] : v['value']) as String)
            .toList();
      } else {
        // Fallback to regular describe if UI API fails
        debugPrint('UI API failed with status ${response.statusCode}, falling back to describe');
        return _getPicklistValuesViaDescribe(objectName, fieldName, useLabel: useLabel);
      }
    } catch (e) {
      debugPrint('Error fetching picklist via UI API: $e');
      // Fallback to describe
      try {
        return await _getPicklistValuesViaDescribe(objectName, fieldName, useLabel: useLabel);
      } catch (e2) {
        debugPrint('Both UI API and Describe failed: $e2');
        rethrow;
      }
    }
  }

  // Private helper method using standard describe (fallback)
  Future<List<String>> _getPicklistValuesViaDescribe(
      String objectName,
      String fieldName, {
        bool useLabel = true,
      })
  async {
    try {
      final describe = await describeObject(objectName);
      final fields = describe['fields'] as List<dynamic>?;

      if (fields == null) {
        throw SalesforceException('No fields found in describe for $objectName');
      }

      final field = fields.firstWhere(
            (f) => f['name'] == fieldName,
        orElse: () => null,
      );

      if (field == null) {
        throw SalesforceException('Field $fieldName not found on $objectName');
      }

      final picklistValues = field['picklistValues'] as List<dynamic>?;
      if (picklistValues == null || picklistValues.isEmpty) {
        return [];
      }

      return picklistValues
          .map((v) => (useLabel ? v['label'] : v['value']) as String)
          .toList();
    } catch (e) {
      debugPrint('Error in describe fallback: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // SOBJECT API - CRUD OPERATIONS
  // ==========================================================================
  Future<SalesforceCreateResponse> create(
    String objectName,
    Map<String, dynamic> data,
  )
  async {
    // if (!isInitialized) {
    //   throw SalesforceException(
    //     'SalesforceService not initialized. Call initialize() first.',
    //   );
    // }

    try {
      final url = '${KApiEndPoints.baseUrl}data/v65.0/sobjects/$objectName/';

      debugPrint('Creating record in $objectName');
      debugPrint('Data: $data');

      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleCreateResponse(response);
    } catch (e) {
      debugPrint('Error creating record: $e');
      throw SalesforceException('Failed to create record: $e');
    }
  }

  /// Get a record by ID
  Future<Map<String, dynamic>> getRecord(
    String objectName,
    String recordId, {
    List<String>? fields,
  })
  async {

    try {
      String url =
          '${KApiEndPoints.baseUrl}data/v65.0/sobjects/$objectName/$recordId';

      if (fields != null && fields.isNotEmpty) {
        url += '?fields=${fields.join(',')}';
      }

      debugPrint('Fetching record: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      return _handleGetResponse(response);
    } catch (e) {
      debugPrint('Error fetching record: $e');
      throw SalesforceException('Failed to fetch record: $e');
    }
  }

  /// Update a record
  Future<SalesforceUpdateResponse> update(
    String objectName,
    String recordId,
    Map<String, dynamic> data,
  )
  async {

    try {
      final url =
          '${KApiEndPoints.baseUrl}data/v65.0/sobjects/$objectName/$recordId';

      debugPrint('Updating record $recordId in $objectName');
      debugPrint('Data: $data');

      final response = await http.patch(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleUpdateResponse(response);
    } catch (e) {
      debugPrint('Error updating record: $e');
      throw SalesforceException('Failed to update record: $e');
    }
  }

  /// Delete a record
  Future<SalesforceDeleteResponse> delete(
    String objectName,
    String recordId,
  )
  async {

    try {
      final url =
          '${KApiEndPoints.baseUrl}data/v65.0/sobjects/$objectName/$recordId';

      debugPrint('Deleting record $recordId from $objectName');

      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      return _handleDeleteResponse(response);
    } catch (e) {
      debugPrint('Error deleting record: $e');
      throw SalesforceException('Failed to delete record: $e');
    }
  }

  // ==========================================================================
  // Get Attachments
  // ==========================================================================

  // Get Content Document Links by Record ID
  Future<ContentDocumentLinkResponse> getContentDocumentLinks(String recordId) async {
    try {
      final soql = '''
        SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, 
               ContentDocument.FileType, ContentDocument.ContentSize, 
               ContentDocument.ContentModifiedDate, ContentDocument.LastModifiedDate, 
               ContentDocument.Owner.Id, ContentDocument.Owner.Name, 
               ContentDocument.Description 
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = '$recordId'
      ''';

      final response = await query(soql);

      final records = response.records.map((record) {
        return ContentDocumentLink(
          contentDocumentId: record['ContentDocumentId'],
          contentDocument: record['ContentDocument'] != null
              ? ContentDocument.fromJson(record['ContentDocument'])
              : null,
        );
      }).toList();

      return ContentDocumentLinkResponse(
        totalSize: response.totalSize,
        done: response.done,
        records: records,
      );
    } catch (e) {
      print('❌ Error fetching content document links: $e');
      return ContentDocumentLinkResponse(
        totalSize: 0,
        done: true,
        records: [],
      );
    }
  }

  // Get Content Version by Content Document ID
  Future<ContentVersionResponse> getContentVersions(String contentDocumentId) async {
    try {
      final soql = '''
        SELECT Id, FileExtension, VersionData 
        FROM ContentVersion 
        WHERE ContentDocumentId = '$contentDocumentId'
      ''';

      final response = await query(soql);

      final records = response.records.map((record) {
        return ContentVersion(
          id: record['Id'],
          fileExtension: record['FileExtension'],
          versionData: record['VersionData'],
        );
      }).toList();

      return ContentVersionResponse(
        totalSize: response.totalSize,
        done: response.done,
        records: records,
      );
    } catch (e) {
      print('❌ Error fetching content versions: $e');
      return ContentVersionResponse(
        totalSize: 0,
        done: true,
        records: [],
      );
    }
  }

  // Get File Data (Base64) from Content Version
  Future<String> getFileData(String contentVersionId) async {

    try {
      final url = '${KApiEndPoints.baseUrl}data/v65.0/sobjects/ContentVersion/$contentVersionId/VersionData';

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Convert bytes to base64 string
        return base64Encode(response.bodyBytes);
      } else {
        throw Exception('Failed to get file data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting file data: $e');
      rethrow;
    }
  }

  // Helper method to get complete file data with metadata
  Future<Map<String, dynamic>> getFileDataByContentDocumentId(String contentDocumentId) async {
    try {
      // Step 1: Get content versions
      final versionsResponse = await getContentVersions(contentDocumentId);

      if (versionsResponse.records.isEmpty) {
        return {
          'success': false,
          'message': 'No content versions found',
        };
      }

      final firstVersion = versionsResponse.records.first;

      if (firstVersion.id == null) {
        return {
          'success': false,
          'message': 'Content Version ID not found',
        };
      }

      // Step 2: Get file data (base64)
      final base64Data = await getFileData(firstVersion.id!);

      return {
        'success': true,
        'fileExtension': firstVersion.fileExtension ?? 'unknown',
        'base64Data': base64Data,
        'contentVersionId': firstVersion.id,
      };
    } catch (e) {
      print('❌ Error getting file data: $e');
      return {
        'success': false,
        'message': 'Failed to load file: $e',
      };
    }
  }

  Future<bool> deleteContentDocument(String contentDocumentId) async {

    try {
      final url = '${KApiEndPoints.baseUrl}data/v65.0/sobjects/ContentDocument/$contentDocumentId';

      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        log('✅ Deleted ContentDocument: $contentDocumentId');
        return true;
      } else {
        log('❌ Failed to delete ContentDocument: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      log('❌ Error deleting ContentDocument: $e');
      return false;
    }
  }

  // ==========================================================================
  // RESPONSE HANDLERS
  // ==========================================================================

  /// Handle query response
  SalesforceQueryResponse _handleResponse(http.Response response, String tag) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return SalesforceQueryResponse.fromJson(data);
    } else {
      final error = _parseError(response);
      throw SalesforceException(
        'Request failed (${response.statusCode}): $error',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }
  }

  /// Handle create response
  SalesforceCreateResponse _handleCreateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return SalesforceCreateResponse.fromJson(data);
    } else {
      final error = _parseError(response);
      throw SalesforceException(
        'Create failed (${response.statusCode}): $error',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }
  }

  /// Handle get response
  Map<String, dynamic> _handleGetResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = _parseError(response);
      throw SalesforceException(
        'Get failed (${response.statusCode}): $error',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }
  }

  /// Handle update response
  SalesforceUpdateResponse _handleUpdateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return SalesforceUpdateResponse.fromJson(data);
    } else {
      final error = _parseError(response);
      throw SalesforceException(
        'Update failed (${response.statusCode}): $error',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }
  }

  /// Handle delete response
  SalesforceDeleteResponse _handleDeleteResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return SalesforceDeleteResponse(success: true);
    } else {
      final error = _parseError(response);
      throw SalesforceException(
        'Delete failed (${response.statusCode}): $error',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }
  }

  // ==========================================================================
  // ERROR PARSING
  // ==========================================================================
  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      // Check for standard Salesforce error format
      if (data is List && data.isNotEmpty) {
        final firstError = data[0];
        if (firstError is Map && firstError.containsKey('message')) {
          return firstError['message'].toString();
        }
      }

      if (data is Map) {
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            final firstError = errors[0];
            if (firstError is Map && firstError.containsKey('message')) {
              return firstError['message'].toString();
            }
          }
        }
      }

      return response.body;
    } catch (e) {
      return 'Unknown error occurred';
    }
  }

  // ==========================================================================
  // ADDITIONAL UTILITY METHODS
  // ==========================================================================

  /// Search records using SOSL
  Future<SalesforceSearchResponse> search(String searchTerm) async {

    try {
      final encodedTerm = Uri.encodeQueryComponent(searchTerm);
      final url =
          '${KApiEndPoints.baseUrl}data/v65.0/search/?q=FIND%20{$encodedTerm}';

      debugPrint('Searching for: $searchTerm');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return SalesforceSearchResponse.fromJson(data);
      } else {
        final error = _parseError(response);
        throw SalesforceException(
          'Search failed (${response.statusCode}): $error',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      debugPrint('Error searching: $e');
      throw SalesforceException('Failed to search: $e');
    }
  }

  /// Get object metadata
  Future<Map<String, dynamic>> describeObject(String objectName) async {

    try {
      final url =
          '${KApiEndPoints.baseUrl}data/v65.0/sobjects/$objectName/describe/';

      debugPrint('Describing object: $objectName');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final error = _parseError(response);
        throw SalesforceException(
          'Describe failed (${response.statusCode}): $error',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      debugPrint('Error describing object: $e');
      throw SalesforceException('Failed to describe object: $e');
    }
  }
}

// ==========================================================================
// RESPONSE MODELS
// ==========================================================================

/// Salesforce Query Response
class SalesforceQueryResponse {
  final int totalSize;
  final bool done;
  final List<Map<String, dynamic>> records;
  final String? nextRecordsUrl;

  SalesforceQueryResponse({
    required this.totalSize,
    required this.done,
    required this.records,
    this.nextRecordsUrl,
  });

  factory SalesforceQueryResponse.fromJson(Map<String, dynamic> json) {
    return SalesforceQueryResponse(
      totalSize: json['totalSize'] ?? 0,
      done: json['done'] ?? true,
      records: (json['records'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      nextRecordsUrl: json['nextRecordsUrl'],
    );
  }
}

/// Salesforce Create Response
class SalesforceCreateResponse {
  final String id;
  final bool success;
  final List<dynamic>? errors;

  SalesforceCreateResponse({
    required this.id,
    required this.success,
    this.errors,
  });

  factory SalesforceCreateResponse.fromJson(Map<String, dynamic> json) {
    return SalesforceCreateResponse(
      id: json['id'] ?? '',
      success: json['success'] ?? false,
      errors: json['errors'],
    );
  }
}

/// Salesforce Update Response
class SalesforceUpdateResponse {
  final bool success;
  final List<dynamic>? errors;

  SalesforceUpdateResponse({
    required this.success,
    this.errors,
  });

  factory SalesforceUpdateResponse.fromJson(Map<String, dynamic> json) {
    return SalesforceUpdateResponse(
      success: json['success'] ?? false,
      errors: json['errors'],
    );
  }
}

/// Salesforce Delete Response
class SalesforceDeleteResponse {
  final bool success;

  SalesforceDeleteResponse({required this.success});
}

/// Salesforce Search Response
class SalesforceSearchResponse {
  final List<Map<String, dynamic>> searchRecords;

  SalesforceSearchResponse({
    required this.searchRecords,
  });

  factory SalesforceSearchResponse.fromJson(Map<String, dynamic> json) {
    return SalesforceSearchResponse(
      searchRecords: (json['searchRecords'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

// ==========================================================================
// EXCEPTIONS
// ==========================================================================

/// Custom exception for Salesforce API errors
class SalesforceException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  SalesforceException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'SalesforceException: $message (Status: $statusCode)';
    }
    return 'SalesforceException: $message';
  }
}
