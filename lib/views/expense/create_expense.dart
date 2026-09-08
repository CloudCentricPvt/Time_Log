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
import 'package:time_log/models/account_list_res.dart';
import 'package:time_log/models/create_expense_payload.dart';
import 'package:time_log/models/create_expense_req.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/utils/constants/k_date_dialog.dart';
import 'package:time_log/utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:time_log/utils/reusable_widgit/k_dropdown.dart';
import 'package:time_log/utils/reusable_widgit/k_info_card.dart';
import 'package:time_log/utils/reusable_widgit/k_textinputform_field.dart';
import 'package:get_storage/get_storage.dart';

import '../../network/salesforce_api_service.dart';

class CreateExpense extends StatefulWidget {
  const CreateExpense({super.key});

  @override
  State<CreateExpense> createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
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
  String? selectedCustomerId; // Store ID instead of name
  String? selectedCustomerName; // Store name for display
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

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat("dd MMM yyyy").format(DateTime.now());
    _loadCategories();
    _loadCustomers();
  }

  // -- Load Categories
  Future<void> _loadCategories() async {
    try {
      // Use the service instance (already available via _controller)
      final picklistValues = await _controller.salesforceService
          .getPicklistValuesUIAPI('Closure_Expense__c', 'Expense_Type__c', recordTypeId: '012000000000000AAA');

      setState(() {
        categories = picklistValues.isNotEmpty
            ? picklistValues
            : _getFallbackCategories(); // fallback if empty
        //_isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Failed to load categories: $e');
      setState(() {
        categories = _getFallbackCategories();
        //_isLoadingCategories = false;
      });
    }
  }

  List<String> _getFallbackCategories() {
    // Keep your old hardcoded list as fallback
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
    // setState(() {
    //   _isLoadingCustomers = true;
    // });

    try {
      // Try to load from cache first
      final cachedCustomers = storage.read<List>('CUSTOMERS');
      if (cachedCustomers != null && cachedCustomers.isNotEmpty) {
        setState(() {
          customers = cachedCustomers
              .map((e) => AccountListRes.fromJson(e as Map<String, dynamic>))
              .toList();
          //_isLoadingCustomers = false;
        });
        return;
      }

      // Fetch from Salesforce
      final fetchedCustomers = await _controller.getCustomers();

      // Cache the results
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
        //_isLoadingCustomers = false;
      });
    } catch (e) {
      debugPrint('Failed to load customers: $e');
      setState(() {
        //_isLoadingCustomers = false;
      });
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
          screenTitle: 'Create Expense',
          showHistory: false,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          spacing: 22,
          children: [
            /*Expanded(
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
                onPressed: () {},
                child: Text('Save as Draft',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
              ),
            ),*/
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
                    : Text('Submit',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                              String? selectedDateStr =
                                  await KDateDialog.selectDate(
                                      context: context);
                              if (selectedDateStr != null) {
                                setState(() =>
                                    dateController.text = selectedDateStr);
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
                          onChanged: (value) =>
                              setState(() => selectedCategory = value),
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

                        // KDropdownField<String>(
                        //   value: selectedCurrency,
                        //   onChanged: (value) =>
                        //       setState(() => selectedCurrency = value),
                        //   title: 'Currency',
                        //   hint: 'Select Currency',
                        //   items: currencies,
                        //   getLabel: (cur) => cur,
                        //   isRequired: true,
                        // ),

                        KDropdownField<String>(
                          value: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                              // Reset customer selection when type changes
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
                            // AccountListRes?
                            onChanged: (value) {
                              setState(() {
                                selectedCustomer = value;
                                selectedCustomerId = value?.id;
                              });
                            },
                            title: 'Customer',
                            hint: 'Select Customer',
                            items: customers,
                            // List<AccountListRes>
                            getLabel: (customer) => customer.name,
                            // Returns the name for display
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
                          // Shows 4 lines, scrolls beyond that
                          minLines: 4, // Ensures 4 lines are always visible
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

                        /*Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            const Text(
                              'Attachment (Bill, Receipt, etc)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            const Text(
                              'Format should be in .pdf .jpeg .png less than 5MB',
                              style: TextStyle(
                                  color: KColors.textGrey, fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(3, (index) {
                            final hasFile = selectedFileNames[index] != null;
                            return Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(right: index < 2 ? 8.0 : 0),
                                child: hasFile
                                    ? _buildFilledSlot(index)
                                    : _buildEmptySlot(index),
                              ),
                            );
                          }),
                        ),*/
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
              // If Has Receipt is unchecked, clear any existing attachments
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
    });
  }

  Widget _buildFilledSlot(int index) {
    final bytes = selectedFileBytes[index];
    final fileName = selectedFileNames[index] ?? '';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return GestureDetector(
      onTap: () => _previewFile(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Picked file/image container
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
                              : Icons.insert_drive_file,
                          color: isPdf ? Colors.red : Colors.grey,
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
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
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

          // Cross icon(remove)
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
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
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
    final isUpload = firstEmpty == index; // next-to-fill slot shows upload icon
    final isNextEmpty = firstEmpty == index;

    return GestureDetector(
      onTap: isNextEmpty ? () => _showPickerOptions(index) : null,
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

  // ==================== PREVIEW FILE ====================
  void _previewFile(int index) async {
    final fileName = selectedFileNames[index] ?? '';
    final bytes = selectedFileBytes[index];
    final fileDataBase64 = selectedFileDataBase64s[index];

    if (bytes != null && !fileName.toLowerCase().endsWith('.pdf')) {
      // Preview Image
      _showImagePreviewDialog(bytes, fileName);
    } else if (fileDataBase64 != null) {
      // Open PDF or other files
      _openFile(fileDataBase64, fileName);
    } else {
      // Fallback: show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot preview this file'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ==================== IMAGE PREVIEW DIALOG ====================
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
              // AppBar for preview
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              // Image
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.fill,
                  //width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== OPEN FILE (PDF, etc) ====================
  Future<void> _openFile(String base64Data, String fileName) async {
    try {
      // Decode base64 to bytes
      final bytes = base64Decode(base64Data);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Open file with default viewer
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        // If can't open, show error
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

  // ==================== NEW: Show Picker Options (Gallery + Camera) ====================
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

  /*void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      var empID = storage.read("EMP_ID");
      var userName = storage.read("User_Id") ?? ""; // userName

      // Determine the related record ID
      String relatedRecordId;
      if (selectedType == "Customer" && selectedCustomer != null) {
        relatedRecordId = selectedCustomer!.id;
      } else {
        relatedRecordId = "0017z00001pcQN2AAM"; // Mock ID for "Other"
      }

      CreateExpensePayload req = CreateExpensePayload(
        employeeId: empID,
        userName: userName,
        expenseDate: DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(dateController.text)),
        expenseType: selectedCategory,
        expenseAmount: double.tryParse(amountController.text) ?? 0,
        description: "${nameController.text}: ${descriptionController.text}",
        modeOfPayment: selectedPaymentMode ?? "Paid By Company",
        relatedObject: "Account",
        relatedRecordId: relatedRecordId,
        hasReceipt: hasReceipt,
        receiptLostReason: hasReceipt ? "" : "No receipt available",
        modeOfTravel: "",
        fromCity: "",
        toCity: "",
        odometerIn: 0,
        odometerOut: 0,
        distanceTravelled: 0,
        fileName: selectedFileNames.firstWhere((n) => n != null,
            orElse: () => null) ??
            "",
        fileData: selectedFileDataBase64s.firstWhere((d) => d != null,
            orElse: () => null) ??
            ""
      );

      bool success = await _controller.createExpense(context, req);
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }*/

  void _unfocusAllFields() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _submitExpense() async {
    // Clear focus first
    _unfocusAllFields();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Get user info
        var empID = storage.read("EMP_ID") ?? "";
        var userName = storage.read("User_Id") ?? "";

        // Determine the related record ID
        String relatedRecordId = "";
        String accountId = "";

        if (selectedType == "Customer" && selectedCustomer != null) {
          relatedRecordId = selectedCustomer!.id;
          accountId = selectedCustomer!.id;
        }else{
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
          expenseDate = DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(dateController.text));
        } catch (e) {
          expenseDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }

        if(hasReceipt){
          if(attachments.isEmpty){
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please attach atleast one receipt."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
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
          //relatedObject: selectedType == "Customer" ? "Account" : "",
          //relatedRecordId: relatedRecordId,
          accountId: accountId,
          //projectId: "",
          //monthlyExpenseId: "",
          hasReceipt: hasReceipt,
          receiptLostReason: hasReceipt ? "" : "No receipt available",
          fileName: attachments.isNotEmpty ? attachments.first['fileName'] : "",
          fileData: attachments.isNotEmpty ? attachments.first['fileData'] : "",
          //modeOfTravel: "",
          //fromCity: "",
          //toCity: "",
          //distanceTravelled: 0,
          //odometerIn: 0,
          //odometerOut: 0,
          //approvalStatus: "Pending",
          //expenseCategory: "",
          //currencyIsoCode: "",
        );

        log("📡 Creating expense with attachments...");

        // Create expense with attachments
        final result = await _controller.createExpenseWithAttachments(
          context: context,
          expensePayload: req,
          attachments: attachments,
          onUploadProgress: (current, total) {
            // Update progress if you want to show a progress dialog
            log("📤 Uploading file $current of $total");
          },
        );

        setState(() => _isLoading = false);

        if (result.success) {
          String message = result.message ?? 'Expense created successfully';

          // Show success with upload status
          if (result.hasUploads) {
            if (result.hasUploadErrors) {
              message = 'Expense created but ${result.totalUploads - result.successfulUploads} file(s) failed to upload';
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
                  content: Text('Expense created with ${result.totalUploads} file(s)'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expense created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }

          //_clearForm();
          Navigator.pop(context);
        } else {
          // Show error
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

  // ==================== FILE PICKER FOR iOS + Android ====================
  Future<void> _pickFileFromFiles(int slotIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      // Validate file size
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

      // iOS Fix: If bytes is null, read from path
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== GALLERY PICKER ====================
  Future<void> _pickFileFromGallery(int slotIndex) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      // Get file size
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

  // ==================== CAMERA CAPTURE ====================
  Future<void> _captureImageFromCamera(int slotIndex) async {
    try {
      // Check if camera is available
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      // Get file size
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

  // Keep the old method for backward compatibility but redirect
  Future<void> _pickFile(int slotIndex) async {
    _showPickerOptions(slotIndex);
  }

  Future<void> _pickFileOld(int slotIndex) async {
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

      // Check if file is a pdf (no image preview)
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
}
