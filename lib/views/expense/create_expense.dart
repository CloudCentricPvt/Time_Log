import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
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

class CreateExpense extends StatefulWidget {
  const CreateExpense({super.key});

  @override
  State<CreateExpense> createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
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
    dateController.text = DateFormat("dd MMM yyyy").format(DateTime.now());
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
          screenTitle: 'Create Expense',
          showHistory: false,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                          leaveTypes: categories,
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
                          leaveTypes: currencies,
                          getLabel: (cur) => cur,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        KDropdownField<String>(
                          value: selectedCustomer,
                          onChanged: (value) => setState(() => selectedCustomer = value),
                          title: 'Customer',
                          hint: 'Select Customer',
                          leaveTypes: customers,
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
                        const SizedBox(height: 20),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {},
                        child: const Text('SAVE AS DRAFT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : _submitExpense,
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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

      CreateExpenseReq req = CreateExpenseReq(
        expenses: [
          ExpensePayload(
            employeeId: empID,
            date: DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(dateController.text)),
            expenseType: selectedCategory,
            expenseAmount: double.tryParse(amountController.text) ?? 0,
            description: "${nameController.text}: ${descriptionController.text}",
            modeOfPayment: "Paid By Company",
            relatedObject: "Account",
            relatedRecordId: "0017z00000Zd0IyAAJ", // Mock ID
            hasReceipt: selectedFileNames.any((n) => n != null),
            receiptLostReason: "",
            modeOfTravel: "Own Car",
            fromCity: "",
            toCity: "",
            odometerIn: 0,
            odometerOut: 0,
            distanceTravelled: 0,
            fileName: selectedFileNames.firstWhere((n) => n != null, orElse: () => null) ?? "",
            fileData: selectedFileDataBase64s.firstWhere((d) => d != null, orElse: () => null) ?? "",
          )
        ]
      );

      bool success = await _controller.createExpense(context, req);
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
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
              ? const Center(child: Icon(Icons.insert_drive_file, color: Colors.grey, size: 32))
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
    final isUpload = firstEmpty == index; // next-to-fill slot shows upload icon
    // Only the next empty slot is tappable
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
