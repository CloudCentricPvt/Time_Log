import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/models/account_list_res.dart';
import 'package:time_log/models/create_expense_req.dart';
import 'package:time_log/models/expense_list_res.dart';
import 'package:time_log/models/expense_list_response.dart';
import 'package:time_log/network/k_network_api_service.dart';
import 'package:time_log/utils/constants/api_container.dart';

import '../models/content_document_link_response.dart';
import '../models/content_version_request.dart';
import '../models/create_expense_payload.dart';
import '../models/expense_create_response.dart';
import '../models/expense_create_result.dart';
import '../models/expense_summary_response.dart';
import '../models/expense_update_result.dart';
import '../network/salesforce_api_service.dart';

class ExpenseController {
  final KNetworkApiServices _networkApiService = KNetworkApiServices();
  final SalesforceAPIService salesforceService;
  final storage = GetStorage();

  ExpenseController(this.salesforceService);

  // ==========================================================================
  // SALESFORCE STANDARD API METHODS
  // ==========================================================================

  Future<ExpenseSummaryResponse> getExpenseSummary(String empId) async {
    try {
      final query = '''
      SELECT Approval_Status__c, SUM(Expense_Amount__c) totalAmount 
      FROM Closure_Expense__c 
      WHERE Employee__c = '$empId' 
      AND Expense_Date__c = THIS_MONTH 
      AND Approval_Status__c IN ('Approved','Pending RM Approval','Pending Finance Approval','Rejected') 
      GROUP BY Approval_Status__c
    ''';

      final response = await salesforceService.query(query);

      // The response is already parsed, just map the records
      final records = response.records.map((record) {
        return ExpenseSummaryRecord(
          approvalStatus: record['Approval_Status__c'] as String?,
          totalAmount: (record['totalAmount'] as num?)?.toDouble(),
        );
      }).toList();

      return ExpenseSummaryResponse(
        totalSize: response.totalSize,
        done: response.done,
        records: records,
      );
    } catch (e) {
      print('❌ Error fetching expense summary: $e');
      return ExpenseSummaryResponse(
        totalSize: 0,
        done: true,
        records: [],
      );
    }
  }

  Future<ExpenseListResponse> getExpensesByEmployee(String employeeId) async { // Expense_Category__c
    try {
      final soql = '''
        SELECT Id, Name, Approval_Status__c, Expense_Type__c, Do_you_have_an_expense_Receipt__c, Expense_Amount__c, Description__c, CreatedDate,
         Expense_Date__c, Mode_of_Payment__c, Mode_of_Travel__c, Employee__r.Id, Employee__r.Name, Project__r.Id,
          Project__r.Name, Monthly_Expense__r.Id, Monthly_Expense__r.Name, Account__r.Id, Account__r.Name, CreatedBy.Id,
           CreatedBy.Name FROM Closure_Expense__c Where Expense_Date__c=THIS_MONTH AND Employee__c = '$employeeId' 
        ORDER BY CreatedDate DESC
      ''';

      final response = await salesforceService.query(soql);

      // Direct mapping to ExpenseListResponse
      return ExpenseListResponse(
        totalSize: response.totalSize,
        done: response.done,
        records: response.records.map((json) => ExpenseRecord.fromJson(json)).toList(),
      );
    } catch (e) {
      print("❌ Error fetching expenses from Salesforce: $e");
      throw Exception('Failed to get expenses: $e');
    }
  }

  Future<List<AccountListRes>> getCustomers({String? searchTerm}) async {

    try {
      String soql = 'SELECT Id, Name FROM Account ORDER BY Name';

      // Add search filter if provided
      if (searchTerm != null && searchTerm.isNotEmpty) {
        soql = "SELECT Id, Name FROM Account WHERE Name LIKE '%$searchTerm%' ORDER BY Name";
      }

      final response = await salesforceService.query(soql);

      return response.records.map((json) => AccountListRes.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      throw SalesforceException('Failed to fetch customers: $e');
    }
  }

  /// Fetch customers with pagination support : NIU (Not in use)
  Future<List<AccountListRes>> getAllCustomers() async {
    try {
      const soql = 'SELECT Id, Name FROM Account ORDER BY Name';
      final records = await salesforceService.queryAll(soql);

      return records.map((json) => AccountListRes.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching all customers: $e');
      throw SalesforceException('Failed to fetch all customers: $e');
    }
  }

  /// Get customer by ID : NIU (Not in use)
  Future<AccountListRes?> getCustomerById(String accountId) async {
    try {
      final response = await salesforceService.getRecord('Account', accountId, fields: ['Id', 'Name']);
      return AccountListRes.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching customer by ID: $e');
      return null;
    }
  }

  // New method to get attachments for an expense
  Future<ContentDocumentLinkResponse> getExpenseAttachments(String expenseId) async {
    try {
      return await salesforceService.getContentDocumentLinks(expenseId);
    } catch (e) {
      print('❌ Error getting expense attachments: $e');
      return ContentDocumentLinkResponse(
        totalSize: 0,
        done: true,
        records: [],
      );
    }
  }

  // New method to get file data
  Future<Map<String, dynamic>> getFileData(String contentDocId) async {
    try {
      return await salesforceService.getFileDataByContentDocumentId(contentDocId);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load file: $e',
      };
    }
  }

  Future<bool> deleteAttachment(String contentDocumentId) async {
    try {
      return await salesforceService.deleteContentDocument(contentDocumentId);
    } catch (e) {
      print('❌ Error deleting attachment: $e');
      return false;
    }
  }

  // ==========================================================================
  // CREATE EXPENSE WITH ATTACHMENTS (Existing)
  // ==========================================================================

  /// Create an expense and return the response
  Future<ExpenseCreateResponse> createExpenseWithResponse(
      BuildContext context,
      CreateExpensePayload payload,
      )
  async {
    try {
      final Map<String, dynamic> payloadMap = payload.toJsonWithNonNull();

      print('📡 API_URL: ${KApiEndPoints.createExpenseNew}');
      print('📡 Payload: $payloadMap');

      final response = await _networkApiService.postRequest(
        payloadMap,
        KApiEndPoints.createExpenseNew,
        context,
      );

      print('📡 Response: $response');

      if (response == null) {
        throw Exception('No response from server');
      }

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final bool? success = response['success'] as bool?;

      if (success == true) {
        final expenseId = response['expenseId']?.toString() ?? '';
        final monthlyExpenseId = response['monthlyExpenseId']?.toString() ?? '';

        // Store the expense ID for later use
        if (expenseId.isNotEmpty) {
          storage.write('LAST_EXPENSE_ID', expenseId);
        }

        return ExpenseCreateResponse(
          success: true,
          expenseId: expenseId,
          monthlyExpenseId: monthlyExpenseId,
          message: response['message'] ?? 'Expense created successfully',
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to create expense');
      }
    } catch (e) {
      print('❌ Error creating expense: $e');
      rethrow;
    }
  }

  // Update the existing createExpense to use the new method
  Future<bool> createExpense(BuildContext context, CreateExpensePayload payload) async {
    try {
      final response = await createExpenseWithResponse(context, payload);
      return response.success;
    } catch (e) {
      print('❌ Error creating expense: $e');
      _showSnackBar(context, 'Error: ${e.toString()}', Colors.red);
      return false;
    }
  }

  /// Create expense with attachments (files)
  Future<ExpenseCreationResult> createExpenseWithAttachments({
    required BuildContext context,
    required CreateExpensePayload expensePayload,
    List<Map<String, String>> attachments = const [],
    Function(int, int)? onUploadProgress,
  })
  async {
    try {
      // Step 1: Create the expense
      print('📝 Creating expense...');
      final expenseResponse = await createExpense(context, expensePayload);

      if (!expenseResponse) {
        throw Exception('Failed to create expense');
      }

      // Get the expense ID from the response
      // You need to modify createExpense to return the ID
      final expenseId = await _getExpenseIdFromResponse();

      if (expenseId == null || expenseId.isEmpty) {
        throw Exception('No expense ID returned');
      }

      print('✅ Expense created with ID: $expenseId');

      // Step 2: Upload attachments if any
      List<ContentVersionResponse> uploadResponses = [];
      int successfulUploads = 0;

      if (attachments.isNotEmpty) {
        print('📤 Uploading ${attachments.length} attachments...');

        uploadResponses = await uploadMultipleFilesToExpense(
          context : context,
          expenseId: expenseId,
          files: attachments,
          onProgress: onUploadProgress,
        );

        successfulUploads = uploadResponses.where((r) => r.success).length;
        print('✅ Successfully uploaded $successfulUploads/${attachments.length} files');
      }

      // Step 3: Return result
      return ExpenseCreationResult(
        success: true,
        expenseId: expenseId,
        uploadResponses: uploadResponses,
        successfulUploads: successfulUploads,
        totalUploads: attachments.length,
        message: 'Expense created successfully with $successfulUploads/${attachments.length} files',
      );

    } catch (e) {
      print('❌ Error creating expense with attachments: $e');
      return ExpenseCreationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Helper to get expense ID from response (you need to implement this based on your API response)
  Future<String?> _getExpenseIdFromResponse() async {
    // This is a placeholder - implement based on your actual response handling
    // You might store the last created expense ID in a variable
    return storage.read('LAST_EXPENSE_ID');
  }

  // ==========================================================================
  // UPDATE EXPENSE WITH ATTACHMENTS
  // ==========================================================================

  /// Update expense with optional new attachments
  ///
  /// [context] - Build context for showing dialogs
  /// [expenseId] - ID of the expense to update
  /// [expensePayload] - The expense data to update
  /// [attachments] - List of new attachments to upload (fileName, fileData)
  /// [keepExistingFile] - Whether to keep existing files or not
  /// [onUploadProgress] - Callback for upload progress
  /// Update expense with attachments using the same pattern as create
  Future<ExpenseUpdateResult> updateExpenseWithAttachments({
    required BuildContext context,
    required String expenseId,
    required CreateExpensePayload expensePayload,
    List<Map<String, String>> attachments = const [],
    bool keepExistingFile = true,
    Function(int current, int total)? onUploadProgress,
  }) async {
    int uploadedCount = 0;
    int totalUploads = attachments.length;

    try {
      // Step 1: Update the expense record using custom API
      final updateSuccess = await _updateExpenseRecord(
        context: context,
        expenseId: expenseId,
        payload: expensePayload,
      );

      if (!updateSuccess) {
        return ExpenseUpdateResult(
          success: false,
          error: 'Failed to update expense record',
        );
      }

      // Step 2: Upload new attachments if any
      if (attachments.isNotEmpty) {
        log('📤 Uploading ${attachments.length} attachments...');

        final uploadResponses = await uploadMultipleFilesToExpense(
          context: context,
          expenseId: expenseId,
          files: attachments,
          onProgress: onUploadProgress,
        );

        uploadedCount = uploadResponses.where((r) => r.success).length;
        log('✅ Successfully uploaded $uploadedCount/${attachments.length} files');
      }

      // Return result
      return ExpenseUpdateResult(
        success: true,
        message: 'Expense updated successfully with $uploadedCount/${attachments.length} files',
        uploadedCount: uploadedCount,
        totalUploads: totalUploads,
        successfulUploads: uploadedCount,
        hasUploads: attachments.isNotEmpty,
        hasUploadErrors: uploadedCount < totalUploads,
      );

    } catch (e) {
      log('❌ Error in updateExpenseWithAttachments: $e');
      return ExpenseUpdateResult(
        success: false,
        error: e.toString(),
        uploadedCount: uploadedCount,
        totalUploads: totalUploads,
        successfulUploads: uploadedCount,
        hasUploads: attachments.isNotEmpty,
        hasUploadErrors: uploadedCount < totalUploads,
      );
    }
  }

  // ==========================================================================
  // PRIVATE: UPDATE EXPENSE RECORD (Using Custom API)
  // ==========================================================================
  Future<bool> _updateExpenseRecord({
    required BuildContext context,
    required String expenseId,
    required CreateExpensePayload payload,
  }) async {
    try {
      // Build the update payload
      final Map<String, dynamic> updateData = {
        'expenseId': expenseId,
        'employeeId': payload.employeeId,
        'expenseType': payload.expenseType,
        'expenseAmount': payload.expenseAmount,
        'description': payload.description,
        'expenseDate': payload.expenseDate,
        'modeOfPayment': payload.modeOfPayment,
        'accountId': payload.accountId,
        'hasReceipt': payload.hasReceipt,
        if (payload.hasReceipt == false) 'receiptLostReason': payload.receiptLostReason,
      };

      // Remove null values
      updateData.removeWhere((key, value) => value == null);
      final response = await _networkApiService.putRequest(
        updateData,
        KApiEndPoints.updateExpense, // You need to add this endpoint
        context,
      );

      log('📡 Update Response: $response');

      if (response == null) {
        log('❌ Update response is null');
        return false;
      }

      if (response is! Map<String, dynamic>) {
        log('❌ Update response is not a Map: $response');
        return false;
      }

      final bool? success = response['status'] as bool?;

      if (success == true) {
        log('✅ Expense updated successfully: $expenseId');
        return true;
      } else {
        final errorMessage = response['message'] ?? 'Failed to update expense';
        log('❌ Failed to update expense: $errorMessage');
        return false;
      }

    } catch (e) {
      log('❌ Error updating expense record: $e');
      return false;
    }
  }

  // ==========================================================================
  // FILE UPLOAD METHODS (Shared between create and update)
  // ==========================================================================


  /// Upload a single file to an expense using ContentVersion
  Future<ContentVersionResponse> uploadFileToExpense({
    required BuildContext context,
    required String expenseId,
    String? fileName,
    required String fileDataBase64,
    String? title,
  })
  async {
    try {
      final url = KApiEndPoints.uploadFile;

      final request = ContentVersionRequest(
        title: fileName ?? title ?? '',
        pathOnClient: fileName ?? '',
        versionData: fileDataBase64,
        firstPublishLocationId: expenseId,
      );

      print('📡 Uploading file to ContentVersion');
      print('📡 Expense ID: $expenseId');
      print('📡 File Name: $fileName');

      final response = await _networkApiService.postRequest(
        request.toJson(),
        url,
        context, // Note: You'll need to pass context or handle this differently
      );

      print('📡 Upload Response: $response');

      if (response != null && response is Map<String, dynamic>) {
        return ContentVersionResponse.fromJson(response);
      } else {
        throw Exception('Failed to upload file: Invalid response');
      }
    } catch (e) {
      print('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Upload multiple files to an expense
  Future<List<ContentVersionResponse>> uploadMultipleFilesToExpense({
    required BuildContext context,
    required String expenseId,
    required List<Map<String, String>> files, // [{fileName, fileData}]
    Function(int, int)? onProgress, // (current, total)
  })
  async {
    final List<ContentVersionResponse> responses = [];
    int successCount = 0;

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = file['fileName'] ?? '';
      final fileData = file['fileData'] ?? '';

      if (fileName.isEmpty || fileData.isEmpty) {
        print('⚠️ Skipping empty file at index $i');
        continue;
      }

      // Update progress
      if (onProgress != null) {
        onProgress(i + 1, files.length);
      }

      try {
        final response = await uploadFileToExpense(
          context :context,
          expenseId: expenseId,
          fileName: fileName,
          fileDataBase64: fileData,
          title: 'Expense Receipt ${i + 1}',
        );
        responses.add(response);
        if (response.success) {
          successCount++;
        }
        print('✅ Uploaded file ${i + 1}/${files.length}: ${response.id}');
      } catch (e) {
        print('❌ Failed to upload file ${i + 1}: $e');
        // Continue with other files even if one fails
      }
    }

    print('✅ Successfully uploaded $successCount/${files.length} files');
    return responses;
  }

 /* /// Upload a single file to an expense using ContentVersion
  Future<ContentVersionResponse> uploadFileToExpense({
    required BuildContext context,
    required String expenseId,
    required String fileName,
    required String fileDataBase64,
    String? title,
  })
  async {
    try {
      final url = KApiEndPoints.uploadFile;

      final request = ContentVersionRequest(
        title: title ?? fileName,
        pathOnClient: fileName,
        versionData: fileDataBase64,
        firstPublishLocationId: expenseId,
      );

      log('📡 Uploading file to ContentVersion');
      log('📡 Expense ID: $expenseId');
      log('📡 File Name: $fileName');

      final response = await _networkApiService.postRequest(
        request.toJson(),
        url,
        context,
      );

      log('📡 Upload Response: $response');

      if (response != null && response is Map<String, dynamic>) {
        return ContentVersionResponse.fromJson(response);
      } else {
        throw Exception('Failed to upload file: Invalid response');
      }
    } catch (e) {
      log('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Upload multiple files to an expense
  Future<List<ContentVersionResponse>> uploadMultipleFilesToExpense({
    required BuildContext context,
    required String expenseId,
    required List<Map<String, String>> files,
    Function(int, int)? onProgress,
  })
  async {
    final List<ContentVersionResponse> responses = [];
    int successCount = 0;

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = file['fileName'] ?? '';
      final fileData = file['fileData'] ?? '';

      if (fileName.isEmpty || fileData.isEmpty) {
        log('⚠️ Skipping empty file at index $i');
        continue;
      }

      if (onProgress != null) {
        onProgress(i + 1, files.length);
      }

      try {
        final response = await uploadFileToExpense(
          context: context,
          expenseId: expenseId,
          fileName: fileName,
          fileDataBase64: fileData,
          title: 'Expense Receipt ${i + 1}',
        );
        responses.add(response);
        if (response.success) {
          successCount++;
        }
        log('✅ Uploaded file ${i + 1}/${files.length}: ${response.id}');
      } catch (e) {
        log('❌ Failed to upload file ${i + 1}: $e');
      }
    }

    log('✅ Successfully uploaded $successCount/${files.length} files');
    return responses;
  }*/

  Future<bool> submitExpenseApproval(BuildContext context, String monthlyExpenseId, String comments) async {
    try {
      var payload = {
        "monthlyExpenseId": monthlyExpenseId,
        "comments": comments,
      };
      print("SUBMIT APPROVAL PAYLOAD: $payload");

      var response = await _networkApiService.postRequest(
        payload,
        KApiEndPoints.submitExpenseApproval,
        context,
      );

      if (response != null) {
        bool isSuccess = response['status'] == true ||
            response['status'] == 200 ||
            response['status'].toString().toLowerCase() == 'true';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ??
                (isSuccess ? 'Submitted for approval' : 'Submission failed')),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
        return isSuccess;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No response from server'),
              backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      print("Error submitting approval: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red),
      );
      return false;
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Helper to get content type from file extension
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

}
