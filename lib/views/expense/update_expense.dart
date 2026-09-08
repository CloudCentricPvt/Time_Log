import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_log/controllers/expense_controller.dart';
import 'package:time_log/models/create_expense_req.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/utils/constants/k_date_dialog.dart';
import 'package:time_log/utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:time_log/utils/reusable_widgit/k_dropdown.dart';
import 'package:time_log/utils/reusable_widgit/k_info_card.dart';
import 'package:time_log/utils/reusable_widgit/k_textinputform_field.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/account_list_res.dart';
import '../../models/content_document_link_response.dart';
import '../../models/expense_list_res.dart';
import '../../models/expense_list_response.dart';
import '../../network/salesforce_api_service.dart';

/*
class UpdateExpense extends StatefulWidget {
  final ExpenseModel expense;

  const UpdateExpense({super.key, required this.expense});

  @override
  State<UpdateExpense> createState() => _UpdateExpenseState();
}

class _UpdateExpenseState extends State<UpdateExpense> {
  final ExpenseController _controller = ExpenseController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = GetStorage();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedCurrency = 'INR - Indian';
  String? selectedCustomer;

  List<String> categories = ['Travel', 'Hotel / Stay', 'Food', 'Miscellaneous'];
  List<String> currencies = ['INR - Indian', 'USD - US Dollar'];
  List<String> customers = ['ABC Pvt Ltd', 'XYZ Corp'];

  bool _isLoading = false;

  // Support up to 3 attachments
  List<String?> selectedFileNames = [null, null, null];
  List<String?> selectedFileDataBase64s = [null, null, null];
  List<Uint8List?> selectedFileBytes = [null, null, null];

  @override
  void initState() {
    super.initState();
    _populateData();
  }

  void _populateData() {
    try {
      if (widget.expense.formattedDate != null) {
        DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(widget.expense.formattedDate!);
        dateController.text = DateFormat("dd MMM yyyy").format(parsedDate);
      }
    } catch (e) {
      dateController.text = widget.expense.formattedDate ?? "";
    }
    
    // Attempt to extract name and description if they were concatenated
    String fullDesc = widget.expense.description ?? "";
    if (fullDesc.contains(":")) {
      var parts = fullDesc.split(":");
      nameController.text = parts[0].trim();
      descriptionController.text = parts.length > 1 ? parts.sublist(1).join(":").trim() : "";
    } else {
      nameController.text = widget.expense.expenseName ?? "";
      descriptionController.text = fullDesc;
    }

    amountController.text = widget.expense.expenseAmount?.toString() ?? "";
    selectedCategory = widget.expense.expenseType;
    
    // We only have one file name in the model, but UI supports 3 slots.
    // For update, we might not have the actual file data bytes unless fetched from a URL, 
    // so we just show the filename in the first slot if available.
    if (widget.expense.fileName != null && widget.expense.fileName!.isNotEmpty) {
      selectedFileNames[0] = widget.expense.fileName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: KColors.appPrimary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: KCustomAppBar(
          screenTitle: 'Update Expense',
          showHistory: false,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          spacing: 22,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: KColors.appPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: KColors.appPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _submitExpense,
                child: _isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text('Update',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                KInfoCard(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        KTextInputFormField(
                          labelText: 'Expense Date (s)',
                          hintText: 'Select date',
                          isRequired: true,
                          controller: dateController,
                          readOnly: true,
                          suffixIcon: IconButton(
                            onPressed: () async {
                              String? selectedDateStr = await KDateDialog.selectDate(context: context);
                              if (selectedDateStr != null) {
                                setState(() => dateController.text = selectedDateStr);
                              }
                            },
                            icon: SvgPicture.asset(KAssets.calenderIcon),
                          ),
                        ),
                        const SizedBox(height: 20),
                        KTextInputFormField(
                          labelText: 'Expense Name',
                          hintText: 'Enter Expense Name',
                          isRequired: true,
                          controller: nameController,
                        ),
                        const SizedBox(height: 20),
                        KDropdownField<String>(
                          value: selectedCategory,
                          onChanged: (value) => setState(() => selectedCategory = value),
                          title: 'Expense Category',
                          hint: 'Select Category',
                          items: categories,
                          getLabel: (cat) => cat,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        KTextInputFormField(
                          labelText: 'Amount',
                          hintText: 'Enter Amount',
                          isRequired: true,
                          controller: amountController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        KDropdownField<String>(
                          value: selectedCurrency,
                          onChanged: (value) => setState(() => selectedCurrency = value),
                          title: 'Currency',
                          hint: 'Select Currency',
                          items: currencies,
                          getLabel: (cur) => cur,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        KDropdownField<String>(
                          value: selectedCustomer,
                          onChanged: (value) => setState(() => selectedCustomer = value),
                          title: 'Customer',
                          hint: 'Select Customer',
                          items: customers,
                          getLabel: (cus) => cus,
                          isRequired: false,
                        ),
                        const SizedBox(height: 20),
                        KTextInputFormField(
                          labelText: 'Description / Remarks',
                          hintText: 'Enter description here..',
                          controller: descriptionController,
                          useMaxLines: true,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Attachment (Bill, Receipt, etc)',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Format should be in .pdf .jpeg .png less than 5MB',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(3, (index) {
                            final hasFile = selectedFileNames[index] != null;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0),
                                child: hasFile
                                    ? _buildFilledSlot(index)
                                    : _buildEmptySlot(index),
                              ),
                            );
                          }),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      var empID = storage.read("EMP_ID");

      var payload = {
        "expenseId": widget.expense.expenseId,
        "employeeId": empID,
        "date": DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(dateController.text)),
        "expenseType": selectedCategory,
        "expenseAmount": double.tryParse(amountController.text) ?? 0,
        "description": "${nameController.text}: ${descriptionController.text}",
        "modeOfPayment": widget.expense.modeOfPayment ?? "Paid By Company",
        "relatedObject": "Account",
        "relatedRecordId": "0017z00000Zd0IyAAJ", // Mock ID
        "hasReceipt": selectedFileNames.any((n) => n != null),
        "receiptLostReason": "",
        "modeOfTravel": widget.expense.modeOfTravel ?? "Own Car",
        "fromCity": widget.expense.fromCity ?? "",
        "toCity": widget.expense.toCity ?? "",
        "odometerIn": widget.expense.odometerIn ?? 0,
        "odometerOut": widget.expense.odometerOut ?? 0,
        "distanceTravelled": widget.expense.distanceTravelled ?? 0,
        // Send file fields if a new file is uploaded
        "fileName": selectedFileNames.firstWhere((n) => n != null, orElse: () => null) ?? "",
        "fileData": selectedFileDataBase64s.firstWhere((d) => d != null, orElse: () => null) ?? "",
      };

      bool success = await _controller.updateExpense(context, payload);
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true); // return true to indicate success
      }
    }
  }

  Widget _buildFilledSlot(int index) {
    final bytes = selectedFileBytes[index];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
            image: bytes != null
                ? DecorationImage(
                    image: MemoryImage(bytes),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: bytes == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.grey, size: 32),
                    if (selectedFileNames[index] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          selectedFileNames[index]!,
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                  ],
                )
              : null,
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedFileNames[index] = null;
                selectedFileDataBase64s[index] = null;
                selectedFileBytes[index] = null;
              });
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlot(int index) {
    final firstEmpty = selectedFileNames.indexOf(null);
    final isUpload = firstEmpty == index;
    final isNextEmpty = firstEmpty == index;
    return GestureDetector(
      onTap: isNextEmpty ? () => _pickFile(index) : null,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.withOpacity(0.04),
        ),
        child: Center(
          child: isUpload
              ? Icon(Icons.upload_rounded, color: Colors.blue.shade400, size: 30)
              : Icon(Icons.add_box_outlined, color: Colors.blue.shade400, size: 30),
        ),
      ),
    );
  }

  Future<void> _pickFile(int slotIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Uint8List? bytes = file.bytes;

      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) {
        throw Exception("Unable to read file");
      }

      final isPdf = file.name.toLowerCase().endsWith('.pdf');

      setState(() {
        selectedFileNames[slotIndex] = file.name;
        selectedFileDataBase64s[slotIndex] = base64Encode(bytes!);
        selectedFileBytes[slotIndex] = isPdf ? null : bytes;
      });
    } catch (e) {
      debugPrint("File Picker Error: $e");
    }
  }

}*/

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_log/controllers/expense_controller.dart';
import 'package:time_log/models/account_list_res.dart';
import 'package:time_log/models/create_expense_payload.dart';
import 'package:time_log/models/expense_list_res.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/utils/constants/k_date_dialog.dart';
import 'package:time_log/utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:time_log/utils/reusable_widgit/k_dropdown.dart';
import 'package:time_log/utils/reusable_widgit/k_info_card.dart';
import 'package:time_log/utils/reusable_widgit/k_textinputform_field.dart';
import 'package:get_storage/get_storage.dart';

import '../../network/salesforce_api_service.dart';
import 'attachment_viewer.dart';

class UpdateExpense extends StatefulWidget {
  final ExpenseRecord expense;

  const UpdateExpense({super.key, required this.expense});

  @override
  State<UpdateExpense> createState() => _UpdateExpenseState();
}

/*
class _UpdateExpenseState extends State<UpdateExpense> {
  final ExpenseController _controller = ExpenseController(SalesforceAPIService());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = GetStorage();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedType = 'Customer';
  AccountListRes? selectedCustomer;
  String? selectedCustomerId;
  String? selectedCustomerName;
  String? selectedCurrency = 'INR - Indian';
  String? selectedPaymentMode = 'Paid By Self';

  bool hasReceipt = true;

  List<String> categories = [];
  List<String> expenseTypes = ['Customer', "Other"];
  List<AccountListRes> customers = [];
  List<String> currencies = ['INR - Indian', 'USD - US Dollar'];
  List<String> paymentModes = ['Paid By Self', 'Paid By Company'];

  bool _isLoading = false;

  // Support up to 3 attachments
  List<String?> selectedFileNames = [null, null, null];
  List<String?> selectedFileDataBase64s = [null, null, null];
  List<Uint8List?> selectedFileBytes = [null, null, null];

  // Image Picker instance
  final ImagePicker _imagePicker = ImagePicker();

  // Original file data for tracking
  String? originalFileName;
  bool hasExistingFile = false;

  @override
  void initState() {
    super.initState();
    _populateData();
    _loadCategories();
    _loadCustomers();
  }

  // -- Load Categories
  Future<void> _loadCategories() async {
    try {
      final picklistValues = await _controller.salesforceService
          .getPicklistValuesUIAPI('Closure_Expense__c', 'Expense_Type__c', recordTypeId: '012000000000000AAA');

      setState(() {
        categories = picklistValues.isNotEmpty
            ? picklistValues
            : _getFallbackCategories();
      });
    } catch (e) {
      debugPrint('Failed to load categories: $e');
      setState(() {
        categories = _getFallbackCategories();
      });
    }
  }

  List<String> _getFallbackCategories() {
    return [
      'Food',
      'Travel',
      'Accommodation',
      'Toll',
      'Miscellaneous',
      "Others"
    ];
  }

  // -- Load Customers
  Future<void> _loadCustomers() async {
    try {
      final cachedCustomers = storage.read<List>('CUSTOMERS');
      if (cachedCustomers != null && cachedCustomers.isNotEmpty) {
        setState(() {
          customers = cachedCustomers
              .map((e) => AccountListRes.fromJson(e as Map<String, dynamic>))
              .toList();
        });
        // After loading customers, try to match the existing customer
        _matchExistingCustomer();
        return;
      }

      final fetchedCustomers = await _controller.getCustomers();
      storage.write(
          'CUSTOMERS',
          fetchedCustomers
              .map((e) => {
            'Id': e.id,
            'Name': e.name,
          })
              .toList());

      setState(() {
        customers = fetchedCustomers;
      });
      _matchExistingCustomer();
    } catch (e) {
      debugPrint('Failed to load customers: $e');
    }
  }

  void _matchExistingCustomer() {
    if (selectedCustomerName != null && selectedCustomerName!.isNotEmpty) {
      final match = customers.firstWhere(
            (c) => c.name.toLowerCase() == selectedCustomerName!.toLowerCase(),
        orElse: () => AccountListRes(id: '', name: ''),
      );
      if (match.id.isNotEmpty) {
        setState(() {
          selectedCustomer = match;
          selectedCustomerId = match.id;
        });
      }
    }
  }

  void _populateData() {
    try {
      // Set date
      if (widget.expense.expenseDate != null && widget.expense.expenseDate!.isNotEmpty) {
        try {
          DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(widget.expense.expenseDate!);
          dateController.text = DateFormat("dd MMM yyyy").format(parsedDate);
        } catch (e) {
          dateController.text = widget.expense.expenseDate ?? "";
        }
      } else {
        dateController.text = DateFormat("dd MMM yyyy").format(DateTime.now());
      }

      // Extract name and description
      String fullDesc = widget.expense.description ?? "";
      if (fullDesc.contains(":")) {
        var parts = fullDesc.split(":");
        nameController.text = parts[0].trim();
        descriptionController.text = parts.length > 1 ? parts.sublist(1).join(":").trim() : "";
      } else {
        nameController.text = widget.expense.name ?? "";
        descriptionController.text = fullDesc;
      }

      // Set amount
      amountController.text = widget.expense.expenseAmount?.toString() ?? "";

      // Set category
      selectedCategory = widget.expense.expenseType;

      // Set payment mode
      selectedPaymentMode = widget.expense.modeOfPayment ?? 'Paid By Self';

      // Set has receipt
      hasReceipt = widget.expense.hasMonthlyExpense; // Using monthly expense as proxy for has receipt
      // Alternatively, check if there's a file name

      // Set customer name if exists
      if (widget.expense.hasAccount) {
        selectedCustomerName = widget.expense.accountName;
        selectedType = 'Customer';
      } else {
        selectedType = 'Other';
      }

      // Check for existing file
      // Note: ExpenseRecord doesn't have fileName directly,
      // we might need to fetch it separately or it's stored elsewhere
      if (widget.expense.description != null && widget.expense.description!.contains('[Attachment: ')) {
        // Extract file name if stored in description
        final match = RegExp(r'\[Attachment: ([^\]]+)\]').firstMatch(widget.expense.description!);
        if (match != null) {
          originalFileName = match.group(1);
          selectedFileNames[0] = originalFileName;
          hasExistingFile = true;
        }
      }
    } catch (e) {
      debugPrint('Error populating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: KColors.appSecondary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: KCustomAppBar(
          screenTitle: 'Update Expense',
          showHistory: false,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          spacing: 22,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: KColors.appPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: KColors.appPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : null, //_submitExpense
                child: _isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text('Update',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 22,
              children: [
                KInfoCard(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        KTextInputFormField(
                          labelText: 'Expense Date (s)',
                          hintText: 'Select date',
                          isRequired: true,
                          controller: dateController,
                          readOnly: true,
                          suffixIcon: IconButton(
                            onPressed: () async {
                              String? selectedDateStr = await KDateDialog.selectDate(context: context);
                              if (selectedDateStr != null) {
                                setState(() => dateController.text = selectedDateStr);
                              }
                            },
                            icon: SvgPicture.asset(KAssets.calenderIcon),
                          ),
                        ),

                        // KTextInputFormField(
                        //   labelText: 'Expense Name',
                        //   hintText: 'Enter Expense Name',
                        //   isRequired: true,
                        //   controller: nameController,
                        // ),

                        KDropdownField<String>(
                          value: selectedCategory,
                          onChanged: (value) => setState(() => selectedCategory = value),
                          title: 'Expense Category',
                          hint: 'Select Category',
                          items: categories,
                          getLabel: (cat) => cat,
                          isRequired: true,
                        ),

                        KTextInputFormField(
                          labelText: 'Amount',
                          hintText: 'Enter Amount',
                          isRequired: true,
                          controller: amountController,
                          keyboardType: TextInputType.number,
                        ),

                        KDropdownField<String>(
                          value: selectedPaymentMode,
                          onChanged: (value) =>
                              setState(() => selectedPaymentMode = value),
                          title: 'Mode of Payment',
                          hint: 'Select Payment Mode',
                          items: paymentModes,
                          getLabel: (mode) => mode,
                          isRequired: true,
                        ),

                        KDropdownField<String>(
                          value: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                              if (value != "Customer") {
                                selectedCustomer = null;
                                selectedCustomerId = null;
                              }
                            });
                          },
                          title: 'Expense Type',
                          hint: 'Select Type',
                          items: expenseTypes,
                          getLabel: (cat) => cat,
                          isRequired: true,
                        ),

                        if (selectedType == "Customer")
                          KDropdownField<AccountListRes>(
                            value: selectedCustomer,
                            onChanged: (value) {
                              setState(() {
                                selectedCustomer = value;
                                selectedCustomerId = value?.id;
                              });
                            },
                            title: 'Customer',
                            hint: 'Select Customer',
                            items: customers,
                            getLabel: (customer) => customer.name,
                            isRequired: selectedType == "Customer",
                          ),

                        // Has Receipt Checkbox
                        _buildHasReceiptCheckbox(),

                        KTextInputFormField(
                          labelText: 'Description / Remarks',
                          hintText: 'Enter description here...',
                          controller: descriptionController,
                          useMaxLines: true,
                          maxLines: 4,
                          minLines: 4,
                        ),

                        // Show attachments section only if Has Receipt is true
                        if (hasReceipt) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              const Text(
                                'Attachment (Bill, Receipt, etc)',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                              ),
                              const Text(
                                'Format should be in .pdf .jpeg .png less than 5MB',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: KColors.textGrey,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            children: List.generate(3, (index) {
                              final hasFile = selectedFileNames[index] != null;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: index < 2 ? 8.0 : 0),
                                  child: hasFile
                                      ? _buildFilledSlot(index)
                                      : _buildEmptySlot(index),
                                ),
                              );
                            }),
                          )
                        ],
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HAS RECEIPT CHECKBOX ====================
  Widget _buildHasReceiptCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: hasReceipt,
          onChanged: (value) {
            setState(() {
              hasReceipt = value ?? true;
              if (!hasReceipt) {
                _clearAllAttachments();
              }
            });
          },
          activeColor: KColors.appPrimary,
          checkColor: Colors.white,
          side: BorderSide(
            color: hasReceipt ? KColors.appPrimary : Colors.grey,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Text(
          'Has Receipt',
          style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          '(Bill/Receipt available)',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ==================== CLEAR ALL ATTACHMENTS ====================
  void _clearAllAttachments() {
    setState(() {
      for (int i = 0; i < selectedFileNames.length; i++) {
        selectedFileNames[i] = null;
        selectedFileDataBase64s[i] = null;
        selectedFileBytes[i] = null;
      }
      hasExistingFile = false;
      originalFileName = null;
    });
  }

  // ==================== FILE SLOTS ====================
  Widget _buildFilledSlot(int index) {
    final bytes = selectedFileBytes[index];
    final fileName = selectedFileNames[index] ?? '';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final isExistingFile = hasExistingFile && index == 0 && bytes == null;

    return GestureDetector(
      onTap: () => _previewFile(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: bytes != null
                  ? DecorationImage(
                image: MemoryImage(bytes),
                fit: BoxFit.cover,
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: (bytes == null || isPdf)
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPdf
                        ? Icons.picture_as_pdf
                        : isExistingFile
                        ? Icons.attach_file
                        : Icons.insert_drive_file,
                    color: isPdf ? Colors.red : (isExistingFile ? KColors.appPrimary : Colors.grey),
                    size: 32,
                  ),
                  if (fileName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        fileName.length > 12
                            ? '${fileName.substring(0, 10)}...'
                            : fileName,
                        style: TextStyle(
                          fontSize: 10,
                          color: isExistingFile ? KColors.appPrimary : Colors.grey.shade700,
                          fontWeight: isExistingFile ? FontWeight.w500 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (isExistingFile)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Existing File',
                        style: TextStyle(
                          fontSize: 8,
                          color: KColors.appPrimary.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            )
                : null,
          ),

          // Preview icon overlay
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.zoom_out_map,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          // Remove icon
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isExistingFile) {
                    // If it's an existing file, just remove the reference
                    hasExistingFile = false;
                    originalFileName = null;
                    selectedFileNames[index] = null;
                  } else {
                    selectedFileNames[index] = null;
                    selectedFileDataBase64s[index] = null;
                    selectedFileBytes[index] = null;
                  }
                });
              },
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot(int index) {
    final firstEmpty = selectedFileNames.indexOf(null);
    final isUpload = firstEmpty == index;

    return GestureDetector(
      onTap: isUpload ? () => _showPickerOptions(index) : null,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
            color: KColors.appPrimary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: KColors.appPrimary.withOpacity(0.04),
        ),
        child: Center(
          child: isUpload
              ? Icon(Icons.upload_rounded, color: KColors.appPrimary, size: 30)
              : Icon(Icons.add_box_outlined,
              color: KColors.appPrimary, size: 30),
        ),
      ),
    );
  }

  // ==================== PICKER OPTIONS ====================
  void _showPickerOptions(int slotIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 40,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Attachment Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPickerOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickFileFromGallery(slotIndex);
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _captureImageFromCamera(slotIndex);
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.folder,
                      label: 'Files',
                      onTap: () {
                        Navigator.pop(context);
                        _pickFileFromFiles(slotIndex);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: KColors.appPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: KColors.appPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FILE PICKERS ====================
  Future<void> _pickFileFromFiles(int slotIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Uint8List? bytes = file.bytes;

      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) {
        throw Exception("Unable to read file");
      }

      final isPdf = file.name.toLowerCase().endsWith('.pdf');

      setState(() {
        // If this slot had an existing file, clear that flag
        if (slotIndex == 0 && hasExistingFile) {
          hasExistingFile = false;
          originalFileName = null;
        }
        selectedFileNames[slotIndex] = file.name;
        selectedFileDataBase64s[slotIndex] = base64Encode(bytes!);
        selectedFileBytes[slotIndex] = isPdf ? null : bytes;
      });
    } catch (e) {
      debugPrint("File Picker Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFileFromGallery(int slotIndex) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      final fileSize = await image.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      final fileName = image.name;

      setState(() {
        if (slotIndex == 0 && hasExistingFile) {
          hasExistingFile = false;
          originalFileName = null;
        }
        selectedFileNames[slotIndex] = fileName;
        selectedFileDataBase64s[slotIndex] = base64Encode(bytes);
        selectedFileBytes[slotIndex] = bytes;
      });
    } catch (e) {
      debugPrint("Gallery Picker Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image from gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureImageFromCamera(int slotIndex) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      final fileSize = await image.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      final fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';

      setState(() {
        if (slotIndex == 0 && hasExistingFile) {
          hasExistingFile = false;
          originalFileName = null;
        }
        selectedFileNames[slotIndex] = fileName;
        selectedFileDataBase64s[slotIndex] = base64Encode(bytes);
        selectedFileBytes[slotIndex] = bytes;
      });
    } catch (e) {
      debugPrint("Camera Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== PREVIEW / VIEW ====================
  void _previewFile(int index) async {
    final fileName = selectedFileNames[index] ?? '';
    final bytes = selectedFileBytes[index];
    final fileDataBase64 = selectedFileDataBase64s[index];

    if (bytes != null && !fileName.toLowerCase().endsWith('.pdf')) {
      _showImagePreviewDialog(bytes, fileName);
    } else if (fileDataBase64 != null) {
      _openFile(fileDataBase64, fileName);
    } else if (hasExistingFile && index == 0) {
      // If it's an existing file, we can't preview without the actual file data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Existing file cannot be previewed. Please upload a new file to view.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot preview this file'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showImagePreviewDialog(Uint8List bytes, String fileName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black87,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(String base64Data, String fileName) async {
    try {
      final bytes = base64Decode(base64Data);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open file: ${result.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== SUBMIT EXPENSE ====================
  */
/*void _submitExpense() async {
    // Clear focus from any field
    FocusManager.instance.primaryFocus?.unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        var empID = storage.read("EMP_ID") ?? "";
        var userName = storage.read("User_Id") ?? "";

        // Determine account ID
        String accountId = "";
        if (selectedType == "Customer" && selectedCustomer != null) {
          accountId = selectedCustomer!.id;
        } else {
          accountId = "0017z00001pcQN2AAM";
        }

        // Get all valid attachments
        List<Map<String, String>> attachments = [];
        for (int i = 0; i < selectedFileNames.length; i++) {
          if (selectedFileNames[i] != null &&
              selectedFileNames[i]!.isNotEmpty &&
              selectedFileDataBase64s[i] != null &&
              selectedFileDataBase64s[i]!.isNotEmpty) {
            attachments.add({
              'fileName': selectedFileNames[i]!,
              'fileData': selectedFileDataBase64s[i]!,
            });
          }
        }

        // Build description
        String description = "";
        if (nameController.text.isNotEmpty) {
          description = nameController.text;
        }
        if (descriptionController.text.isNotEmpty) {
          description = description.isEmpty
              ? descriptionController.text
              : "$description: ${descriptionController.text}";
        }

        // Parse expense date
        String expenseDate;
        try {
          expenseDate = DateFormat('yyyy-MM-dd')
              .format(DateFormat('dd MMM yyyy').parse(dateController.text));
        } catch (e) {
          expenseDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }

        // Validate receipt
        if (hasReceipt && attachments.isEmpty && !hasExistingFile) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please attach at least one receipt."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Create the expense payload
        CreateExpensePayload req = CreateExpensePayload(
          employeeId: empID,
          userName: userName,
          expenseType: selectedCategory ?? "",
          expenseAmount: double.tryParse(amountController.text) ?? 0,
          description: description,
          expenseDate: expenseDate,
          modeOfPayment: selectedPaymentMode ?? "Paid By Self",
          accountId: accountId,
          hasReceipt: hasReceipt,
          receiptLostReason: hasReceipt ? "" : "No receipt available",
          fileName: attachments.isNotEmpty ? attachments.first['fileName'] : "",
          fileData: attachments.isNotEmpty ? attachments.first['fileData'] : "",
        );

        log("📡 Updating expense...");

        // Create expense with attachments
        final result = await _controller.updateExpenseWithAttachments(
          context: context,
          expenseId: widget.expense.id,
          expensePayload: req,
          attachments: attachments,
          keepExistingFile: hasExistingFile && attachments.isEmpty,
          onUploadProgress: (current, total) {
            log("📤 Uploading file $current of $total");
          },
        );

        setState(() => _isLoading = false);

        if (result.success) {
          String message = result.message ?? 'Expense updated successfully';

          if (result.hasUploads) {
            if (result.hasUploadErrors) {
              message = 'Expense updated but ${result.totalUploads - result.successfulUploads} file(s) failed to upload';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Expense updated with ${result.totalUploads} file(s)'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expense updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }

          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        log("❌ Error in _submitExpense: $e");
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*//*

}*/

class _UpdateExpenseState extends State<UpdateExpense> {
  final ExpenseController _controller = ExpenseController(SalesforceAPIService());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = GetStorage();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedType = 'Customer';
  AccountListRes? selectedCustomer;
  String? selectedCustomerId;
  String? selectedCustomerName;
  String? selectedCurrency = 'INR - Indian';
  String? selectedPaymentMode = 'Paid By Self';

  bool hasReceipt = true;

  List<String> categories = [];
  List<String> expenseTypes = ['Customer', "Other"];
  List<AccountListRes> customers = [];
  List<String> currencies = ['INR - Indian', 'USD - US Dollar'];
  List<String> paymentModes = ['Paid By Self', 'Paid By Company'];

  bool _isLoading = false;
  bool _isLoadingAttachments = false;
  bool _isDeleting = false;

  // Attachment management
  List<String?> selectedFileNames = [null, null, null];
  List<String?> selectedFileDataBase64s = [null, null, null];
  List<Uint8List?> selectedFileBytes = [null, null, null];

  // Existing attachments from Salesforce
  List<ContentDocumentLink> _existingAttachments = [];

  // Image Picker instance
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _populateData();
    _loadCategories();
    _loadCustomers();
    _loadExistingAttachments();
  }

  // ==========================================================================
  // LOAD EXISTING ATTACHMENTS
  // ==========================================================================

  Future<void> _loadExistingAttachments() async {
    if (widget.expense.id == null) return;

    setState(() => _isLoadingAttachments = true);

    try {
      final response = await _controller.getExpenseAttachments(widget.expense.id!);
      setState(() {
        _existingAttachments = response.records;
        _populateAttachmentSlots();
        _isLoadingAttachments = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading attachments: $e');
      setState(() => _isLoadingAttachments = false);
    }
  }

  void _populateAttachmentSlots() {
    // Clear existing slots first
    for (int i = 0; i < selectedFileNames.length; i++) {
      selectedFileNames[i] = null;
      selectedFileDataBase64s[i] = null;
      selectedFileBytes[i] = null;
    }

    // Fill slots with existing attachments (max 3)
    for (int i = 0; i < _existingAttachments.length && i < 3; i++) {
      final attachment = _existingAttachments[i];
      final doc = attachment.contentDocument;
      if (doc != null) {
        selectedFileNames[i] = doc.title ?? 'Attachment ${i + 1}';
        // Mark as existing file (no bytes)
        selectedFileBytes[i] = null;
        selectedFileDataBase64s[i] = null;
      }
    }
  }

  // ==========================================================================
  // LOAD CATEGORIES & CUSTOMERS
  // ==========================================================================

  Future<void> _loadCategories() async {
    try {
      final picklistValues = await _controller.salesforceService
          .getPicklistValuesUIAPI('Closure_Expense__c', 'Expense_Type__c', recordTypeId: '012000000000000AAA');

      setState(() {
        categories = picklistValues.isNotEmpty
            ? picklistValues
            : _getFallbackCategories();
      });
    } catch (e) {
      debugPrint('Failed to load categories: $e');
      setState(() {
        categories = _getFallbackCategories();
      });
    }
  }

  List<String> _getFallbackCategories() {
    return ['Food', 'Travel', 'Accommodation', 'Toll', 'Miscellaneous', "Others"];
  }

  Future<void> _loadCustomers() async {
    try {
      final cachedCustomers = storage.read<List>('CUSTOMERS');
      if (cachedCustomers != null && cachedCustomers.isNotEmpty) {
        setState(() {
          customers = cachedCustomers
              .map((e) => AccountListRes.fromJson(e as Map<String, dynamic>))
              .toList();
        });
        _matchExistingCustomer();
        return;
      }

      final fetchedCustomers = await _controller.getCustomers();
      storage.write(
          'CUSTOMERS',
          fetchedCustomers
              .map((e) => {'Id': e.id, 'Name': e.name})
              .toList());

      setState(() {
        customers = fetchedCustomers;
      });
      _matchExistingCustomer();
    } catch (e) {
      debugPrint('Failed to load customers: $e');
    }
  }

  void _matchExistingCustomer() {
    if (selectedCustomerName != null && selectedCustomerName!.isNotEmpty) {
      final match = customers.firstWhere(
            (c) => c.name.toLowerCase() == selectedCustomerName!.toLowerCase(),
        orElse: () => AccountListRes(id: '', name: ''),
      );
      if (match.id.isNotEmpty) {
        setState(() {
          selectedCustomer = match;
          selectedCustomerId = match.id;
        });
      }
    }
  }

  // ==========================================================================
  // POPULATE DATA
  // ==========================================================================

  void _populateData() {
    try {
      // Set date
      if (widget.expense.expenseDate != null && widget.expense.expenseDate!.isNotEmpty) {
        try {
          DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(widget.expense.expenseDate!);
          dateController.text = DateFormat("dd MMM yyyy").format(parsedDate);
        } catch (e) {
          dateController.text = widget.expense.expenseDate ?? "";
        }
      } else {
        dateController.text = DateFormat("dd MMM yyyy").format(DateTime.now());
      }

      // Extract name and description
      String fullDesc = widget.expense.description ?? "";
      if (fullDesc.contains(":")) {
        var parts = fullDesc.split(":");
        nameController.text = parts[0].trim();
        descriptionController.text = parts.length > 1 ? parts.sublist(1).join(":").trim() : "";
      } else {
        nameController.text = widget.expense.name ?? "";
        descriptionController.text = fullDesc;
      }

      // Set amount
      amountController.text = widget.expense.expenseAmount?.toString() ?? "";

      // Set category
      selectedCategory = widget.expense.expenseType;

      // Set payment mode
      selectedPaymentMode = widget.expense.modeOfPayment ?? 'Paid By Self';

      // Set has receipt
      hasReceipt = widget.expense.hasAnyReceipt;

      // Set customer name if exists
      if (widget.expense.hasAccount) {
        selectedCustomerName = widget.expense.accountName;
        selectedType = 'Customer';
      } else {
        selectedType = 'Other';
      }
    } catch (e) {
      debugPrint('Error populating data: $e');
    }
  }

  // ==========================================================================
  // ATTACHMENT MANAGEMENT - DELETE IMMEDIATELY
  // ==========================================================================

  // Check if a slot has an existing attachment from Salesforce
  bool _isExistingAttachment(int index) {
    return index < _existingAttachments.length &&
        selectedFileBytes[index] == null &&
        selectedFileNames[index] != null;
  }

  // Get the content document ID for an existing attachment
  String? _getContentDocumentId(int index) {
    if (index < _existingAttachments.length) {
      return _existingAttachments[index].contentDocumentId;
    }
    return null;
  }

  String? _getFileExtension(int index) {
    if (index < _existingAttachments.length) {
      return _existingAttachments[index].contentDocument?.fileExtension;
    }
    return null;
  }

  // Delete an existing attachment immediately (with confirmation)
  Future<void> _deleteExistingAttachment(int index) async {
    final contentDocId = _getContentDocumentId(index);
    if (contentDocId == null) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Delete Attachment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete this attachment?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'File: ${selectedFileNames[index] ?? 'Unknown'}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: KColors.appPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading indicator
    setState(() => _isDeleting = true);

    try {
      // Call delete API immediately
      final success = await _controller.deleteAttachment(contentDocId);

      if (success) {
        // Remove from existing attachments list
        setState(() {
          _existingAttachments.removeAt(index);
          // Clear the slot
          selectedFileNames[index] = null;
          selectedFileDataBase64s[index] = null;
          selectedFileBytes[index] = null;
          _isDeleting = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attachment deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete attachment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting attachment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add a new file to a slot
  Future<void> _addNewFile(int slotIndex, Uint8List bytes, String fileName) async {
    // If this slot already has an existing attachment, ask if they want to replace
    if (_isExistingAttachment(slotIndex)) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Replace Attachment?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This slot already has an existing attachment.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Existing: ${selectedFileNames[slotIndex] ?? 'Unknown'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New: $fileName',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: KColors.appPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ The existing file will be permanently deleted.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Delete the existing attachment immediately
      final contentDocId = _getContentDocumentId(slotIndex);
      if (contentDocId != null) {
        setState(() => _isDeleting = true);
        try {
          await _controller.deleteAttachment(contentDocId);
          _existingAttachments.removeAt(slotIndex);
        } catch (e) {
          debugPrint('Error deleting existing file: $e');
        }
        setState(() => _isDeleting = false);
      }
    }

    // Add the new file
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    setState(() {
      selectedFileNames[slotIndex] = fileName;
      selectedFileDataBase64s[slotIndex] = base64Encode(bytes);
      selectedFileBytes[slotIndex] = isPdf ? null : bytes;
    });
  }

  // Clear a slot (remove file)
  void _clearSlot(int index) {
    setState(() {
      selectedFileNames[index] = null;
      selectedFileDataBase64s[index] = null;
      selectedFileBytes[index] = null;
    });
  }

  // ==========================================================================
  // BUILD UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: KColors.appSecondary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: KCustomAppBar(
          screenTitle: 'Update Expense',
          showHistory: false,
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: _isDeleting
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deleting attachment...'),
          ],
        ),
      )
          : _buildBody(),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        spacing: 22,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: const BorderSide(color: KColors.appPrimary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isLoading || _isDeleting
                  ? null
                  : () => Navigator.pop(context),
              child: Text('Cancel',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1)),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: KColors.appPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isLoading || _isDeleting ? null : _submitExpense,
              child: _isLoading
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text('Update',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                      color: Colors.white,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 22,
            children: [
              KInfoCard(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      _buildDateField(),
                      _buildCategoryField(),
                      _buildAmountField(),
                      _buildPaymentModeField(),
                      _buildExpenseTypeField(),
                      if (selectedType == "Customer") _buildCustomerField(),
                      _buildHasReceiptCheckbox(),
                      _buildDescriptionField(),
                      if (hasReceipt) _buildAttachmentsSection(),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // FORM FIELDS
  // ==========================================================================

  Widget _buildDateField() {
    return KTextInputFormField(
      labelText: 'Expense Date (s)',
      hintText: 'Select date',
      isRequired: true,
      controller: dateController,
      readOnly: true,
      suffixIcon: IconButton(
        onPressed: () async {
          String? selectedDateStr = await KDateDialog.selectDate(context: context);
          if (selectedDateStr != null) {
            setState(() => dateController.text = selectedDateStr);
          }
        },
        icon: SvgPicture.asset(KAssets.calenderIcon),
      ),
    );
  }

  Widget _buildCategoryField() {
    return KDropdownField<String>(
      value: selectedCategory,
      onChanged: (value) => setState(() => selectedCategory = value),
      title: 'Expense Category',
      hint: 'Select Category',
      items: categories,
      getLabel: (cat) => cat,
      isRequired: true,
    );
  }

  Widget _buildAmountField() {
    return KTextInputFormField(
      labelText: 'Amount',
      hintText: 'Enter Amount',
      isRequired: true,
      controller: amountController,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPaymentModeField() {
    return KDropdownField<String>(
      value: selectedPaymentMode,
      onChanged: (value) => setState(() => selectedPaymentMode = value),
      title: 'Mode of Payment',
      hint: 'Select Payment Mode',
      items: paymentModes,
      getLabel: (mode) => mode,
      isRequired: true,
    );
  }

  Widget _buildExpenseTypeField() {
    return KDropdownField<String>(
      value: selectedType,
      onChanged: (value) {
        setState(() {
          selectedType = value;
          if (value != "Customer") {
            selectedCustomer = null;
            selectedCustomerId = null;
          }
        });
      },
      title: 'Expense Type',
      hint: 'Select Type',
      items: expenseTypes,
      getLabel: (cat) => cat,
      isRequired: true,
    );
  }

  Widget _buildCustomerField() {
    return KDropdownField<AccountListRes>(
      value: selectedCustomer,
      onChanged: (value) {
        setState(() {
          selectedCustomer = value;
          selectedCustomerId = value?.id;
        });
      },
      title: 'Customer',
      hint: 'Select Customer',
      items: customers,
      getLabel: (customer) => customer.name,
      isRequired: selectedType == "Customer",
    );
  }

  Widget _buildDescriptionField() {
    return KTextInputFormField(
      labelText: 'Description / Remarks',
      hintText: 'Enter description here...',
      controller: descriptionController,
      useMaxLines: true,
      maxLines: 4,
      minLines: 4,
    );
  }

  // ==========================================================================
  // HAS RECEIPT CHECKBOX
  // ==========================================================================

  Widget _buildHasReceiptCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: hasReceipt,
          onChanged: (value) {
            setState(() {
              hasReceipt = value ?? true;
              if (!hasReceipt) {
                _clearAllAttachments();
              }
            });
          },
          activeColor: KColors.appPrimary,
          checkColor: Colors.white,
          side: BorderSide(
            color: hasReceipt ? KColors.appPrimary : Colors.grey,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Text(
          'Has Receipt',
          style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          '(Bill/Receipt available)',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ATTACHMENTS SECTION
  // ==========================================================================

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attachment (Bill, Receipt, etc)',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
            if (_isLoadingAttachments)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const Text(
          'Format should be in .pdf .jpeg .png less than 5MB (Max 3 files)',
          style: TextStyle(
              fontFamily: 'Poppins',
              color: KColors.textGrey,
              fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            final hasFile = selectedFileNames[index] != null;
            final isExisting = _isExistingAttachment(index);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0),
                child: hasFile
                    ? _buildFilledSlot(index, isExisting)
                    : _buildEmptySlot(index),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==========================================================================
  // ATTACHMENT SLOTS
  // ==========================================================================

  Widget _buildFilledSlot(int index, bool isExisting) {
    final bytes = selectedFileBytes[index];
    final fileName = selectedFileNames[index] ?? '';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return GestureDetector(
      onTap: () {
        if (isExisting) {
          // -- For existing attachments, we can't preview without the file data
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Existing file cannot be previewed. Download the file to view.'),
          //     backgroundColor: Colors.orange,
          //   ),
          // );
          final contentDocId = _getContentDocumentId(index);
          final fileExtension = _getFileExtension(index);
          if (contentDocId != null) {
            _showAttachment(contentDocId, fileName, fileExtension);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid file reference'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (bytes != null) {
          _showImagePreviewDialog(bytes, fileName);
        } else if (selectedFileDataBase64s[index] != null) {
          _openFile(selectedFileDataBase64s[index]!, fileName);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: (bytes != null && !isPdf)
                  ? DecorationImage(
                image: MemoryImage(bytes),
                fit: BoxFit.cover,
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: isExisting
                  ? Border.all(color: KColors.appPrimary.withOpacity(0.3), width: 2)
                  : null,
            ),
            child: (bytes == null || isPdf)
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPdf
                        ? Icons.picture_as_pdf
                        : isExisting
                        ? Icons.cloud_done
                        : Icons.insert_drive_file,
                    color: isPdf
                        ? Colors.red
                        : isExisting
                        ? KColors.appPrimary
                        : Colors.grey,
                    size: 32,
                  ),
                  if (fileName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                      child: Text(
                        fileName.length > 12
                            ? '${fileName.substring(0, 10)}...'
                            : fileName,
                        style: TextStyle(
                          fontSize: 10,
                          color: isExisting ? KColors.appPrimary : Colors.grey.shade700,
                          fontWeight: isExisting ? FontWeight.w500 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (isExisting)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Saved',
                        style: TextStyle(
                          fontSize: 8,
                          color: KColors.appPrimary.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            )
                : null,
          ),

          // Preview icon overlay for non-existing files
          if (!isExisting && bytes != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.zoom_out_map,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          // Delete/Clear button
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                if (isExisting) {
                  // Show delete confirmation for existing attachment
                  _deleteExistingAttachment(index);
                } else {
                  // Just clear the slot for new file
                  _clearSlot(index);
                }
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  //color: isExisting ? Colors.red : Colors.grey,
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExisting ? Icons.delete : Icons.close,
                  color: Colors.white,
                  size: isExisting ? 14 : 16,
                ),
              ),
            ),
          ),

          // -- Existing file badge
          // if (isExisting)
          //   Positioned(
          //     top: 4,
          //     left: 4,
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //       decoration: BoxDecoration(
          //         color: KColors.appPrimary.withOpacity(0.9),
          //         borderRadius: BorderRadius.circular(4),
          //       ),
          //       child: const Text(
          //         'Saved',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 8,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  void _showAttachment(String contentDocumentId, String? fileName, String? fileExtension) {
    showDialog(
      context: context,
      builder: (context) => AttachmentViewerDialog(
        expenseId: widget.expense.id,
        contentDocumentId: contentDocumentId,
        title: fileName ?? 'Attachment',
        fileExtension: fileExtension ?? "jpg",
        controller: _controller,
      ),
    );
  }

  Widget _buildEmptySlot(int index) {
    // Count files that are actually in slots (both existing and new)
    final occupiedSlots = selectedFileNames.where((name) => name != null).length;

    // Check if this specific slot is empty
    final isSlotEmpty = selectedFileNames[index] == null;

    // Disable only if we have 3 files already and this slot is empty
    final isDisabled = occupiedSlots >= 3 && isSlotEmpty;

    return GestureDetector(
      onTap: isDisabled
          ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 3 attachments allowed. Delete an existing attachment to add more.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
          : () => _showPickerOptions(index),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled ? Colors.grey[300]! : KColors.appPrimary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isDisabled
              ? Colors.grey[50]
              : KColors.appPrimary.withOpacity(0.04),
        ),
        child: Center(
          child: isDisabled
              ? Icon(Icons.block, color: Colors.grey[400], size: 30)
              : Icon(Icons.add_box_outlined,
              color: KColors.appPrimary, size: 30),
        ),
      ),
    );
  }

  // ==========================================================================
  // PICKER OPTIONS
  // ==========================================================================

  void _showPickerOptions(int slotIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 40,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Attachment Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPickerOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickFileFromGallery(slotIndex);
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _captureImageFromCamera(slotIndex);
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.folder,
                      label: 'Files',
                      onTap: () {
                        Navigator.pop(context);
                        _pickFileFromFiles(slotIndex);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  })
  {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: KColors.appPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: KColors.appPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FILE PICKERS
  // ==========================================================================

  Future<void> _pickFileFromFiles(int slotIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Uint8List? bytes = file.bytes;

      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) {
        throw Exception("Unable to read file");
      }

      await _addNewFile(slotIndex, bytes, file.name);
    } catch (e) {
      debugPrint("File Picker Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFileFromGallery(int slotIndex) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      final fileSize = await image.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      final fileName = image.name;

      await _addNewFile(slotIndex, bytes, fileName);
    } catch (e) {
      debugPrint("Gallery Picker Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image from gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureImageFromCamera(int slotIndex) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      final fileSize = await image.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      final fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _addNewFile(slotIndex, bytes, fileName);
    } catch (e) {
      debugPrint("Camera Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================================
  // PREVIEW / VIEW
  // ==========================================================================

  void _showImagePreviewDialog(Uint8List bytes, String fileName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black87,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(String base64Data, String fileName) async {
    try {
      final bytes = base64Decode(base64Data);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open file: ${result.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================================
  // CLEAR ALL ATTACHMENTS
  // ==========================================================================

  void _clearAllAttachments() {
    // Delete all existing attachments immediately
    for (int i = 0; i < _existingAttachments.length; i++) {
      final docId = _existingAttachments[i].contentDocumentId;
      if (docId != null) {
        _controller.deleteAttachment(docId);
      }
    }
    _existingAttachments.clear();

    setState(() {
      for (int i = 0; i < selectedFileNames.length; i++) {
        selectedFileNames[i] = null;
        selectedFileDataBase64s[i] = null;
        selectedFileBytes[i] = null;
      }
    });
  }

  // ==========================================================================
  // SUBMIT EXPENSE
  // ==========================================================================

  void _submitExpense() async {
    // Clear focus from any field
    FocusManager.instance.primaryFocus?.unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        var empID = storage.read("EMP_ID") ?? "";
        var userName = storage.read("User_Id") ?? "";

        // Determine account ID
        String accountId = "";
        if (selectedType == "Customer" && selectedCustomer != null) {
          accountId = selectedCustomer!.id;
        } else {
          accountId = "0017z00001pcQN2AAM";
        }

        // Get all new attachments (only those with file data)
        List<Map<String, String>> newAttachments = [];
        for (int i = 0; i < selectedFileNames.length; i++) {
          if (selectedFileNames[i] != null &&
              selectedFileNames[i]!.isNotEmpty &&
              selectedFileDataBase64s[i] != null &&
              selectedFileDataBase64s[i]!.isNotEmpty) {
            newAttachments.add({
              'fileName': selectedFileNames[i]!,
              'fileData': selectedFileDataBase64s[i]!,
            });
          }
        }

        // Build description
        String description = "";
        description = descriptionController.text;
        // if (nameController.text.isNotEmpty) {
        //   description = descriptionController.text;
        // }
        // if (descriptionController.text.isNotEmpty) {
        //   description = description.isEmpty
        //       ? descriptionController.text
        //       : "$description: ${descriptionController.text}";
        // }

        // Parse expense date
        String expenseDate;
        try {
          expenseDate = DateFormat('yyyy-MM-dd')
              .format(DateFormat('dd MMM yyyy').parse(dateController.text));
        } catch (e) {
          expenseDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }

        // Validate receipt
        if (hasReceipt &&
            newAttachments.isEmpty &&
            _existingAttachments.isEmpty) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please attach at least one receipt."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Log what we're doing
        log("📡 Updating expense...");
        log("   - New attachments: ${newAttachments.length}");
        log("   - Existing attachments kept: ${_existingAttachments.length}");

        // Create the expense payload
        CreateExpensePayload req = CreateExpensePayload(
          employeeId: empID,
          userName: userName,
          expenseType: selectedCategory ?? "",
          expenseAmount: double.tryParse(amountController.text) ?? 0,
          description: description,
          expenseDate: expenseDate,
          modeOfPayment: selectedPaymentMode ?? "Paid By Self",
          accountId: accountId,
          hasReceipt: hasReceipt,
          receiptLostReason: hasReceipt ? "" : "No receipt available",
          fileName: newAttachments.isNotEmpty ? newAttachments.first['fileName'] : "",
          fileData: newAttachments.isNotEmpty ? newAttachments.first['fileData'] : "",
        );

        // Update expense with new attachments
        final result = await _controller.updateExpenseWithAttachments(
          context: context,
          expenseId: widget.expense.id,
          expensePayload: req,
          attachments: newAttachments,
          keepExistingFile: false, // We already handled existing files
          onUploadProgress: (current, total) {
            log("📤 Uploading file $current of $total");
          },
        );

        setState(() => _isLoading = false);

        if (result.success) {
          String message = result.message ?? 'Expense updated successfully';

          if (result.hasUploads && result.successfulUploads > 0) {
            message = 'Expense updated with ${result.successfulUploads} file(s) uploaded';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        log("❌ Error in _submitExpense: $e");
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}