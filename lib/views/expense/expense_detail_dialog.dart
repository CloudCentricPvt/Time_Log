import 'package:flutter/material.dart';
import 'package:time_log/controllers/expense_controller.dart';
import 'package:time_log/utils/constants/k_colors.dart';

import '../../models/content_document_link_response.dart';
import '../../utils/constants/k_fonts.dart';
import 'attachment_viewer.dart';

class ExpenseDetailDialog extends StatefulWidget {
  final String? id;
  final String? title;
  final int statusColor;
  final double? amount;
  final String? status;
  final String? category;
  final String? customer;
  final String? date;
  final String? desc;
  final String? submittedDate;
  final String? approvedBy;
  final String? rejectedBy;
  final ExpenseController controller; // Add this
  final VoidCallback? onAttachmentTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onSubmitTap;

  const ExpenseDetailDialog({
    super.key,
    this.id,
    this.title,
    required this.statusColor,
    this.amount,
    this.status,
    this.category,
    this.customer,
    this.date,
    this.desc,
    this.submittedDate,
    this.approvedBy,
    this.rejectedBy,
    required this.controller, // Make required
    this.onAttachmentTap,
    this.onEditTap,
    this.onSubmitTap,
  });

  @override
  State<ExpenseDetailDialog> createState() => _ExpenseDetailDialogState();
}

class _ExpenseDetailDialogState extends State<ExpenseDetailDialog> {
  List<ContentDocumentLink> _attachments = [];
  bool _isLoadingAttachments = false;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    if (widget.id == null) return;

    setState(() => _isLoadingAttachments = true);

    try {
      final attachments = await widget.controller.getExpenseAttachments(widget.id!);
      setState(() {
        _attachments = attachments.records;
        _isLoadingAttachments = false;
      });
    } catch (e) {
      setState(() => _isLoadingAttachments = false);
      print('❌ Error loading attachments: $e');
    }
  }

  void _showAttachment(ContentDocumentLink attachment) {
    final contentDoc = attachment.contentDocument;
    if (contentDoc == null || attachment.contentDocumentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid attachment data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AttachmentViewerDialog(
        expenseId: widget.id!,
        contentDocumentId: attachment.contentDocumentId!,
        title: contentDoc.title ?? 'Attachment',
        fileExtension: contentDoc.fileExtension,
        controller: widget.controller,
      ),
    );
  }

  IconData _getFileIcon(String? extension) {
    final ext = extension?.toLowerCase() ?? '';
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Icons.image;
    } else if (ext == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      return Icons.description;
    } else if (['xls', 'xlsx'].contains(ext)) {
      return Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(ext)) {
      return Icons.slideshow;
    } else if (ext == 'txt') {
      return Icons.text_fields;
    }
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isRejected = widget.status?.toLowerCase() == 'rejected';
    final isDraft = widget.status?.toLowerCase() == 'draft';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: status chip + close button
              _buildHeader(context),
              const SizedBox(height: 4),

              // Title
              _buildTitle(),
              const SizedBox(height: 12),

              // Info fields (scrollable if needed)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Category', widget.category),
                      _buildInfoRow('Customer', widget.customer),
                      _buildInfoRow('Expense Date(s)', widget.date),
                      _buildInfoRow('Description', widget.desc, maxLines: 4),
                      _buildAttachmentsSection(),
                      //const Divider(thickness: 0.6, color: Colors.grey),
                      //_buildApprovalSection(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Submit button for Draft/Rejected
                  if ((isDraft || isRejected) && widget.onSubmitTap != null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.appPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onSubmitTap!();
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Submit for Approval',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Edit button only for Rejected
                  if (isRejected && widget.onEditTap != null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEditTap!();
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        'Edit',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== PRIVATE BUILDERS =====

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Status: ',
              style: KTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              color: Color(widget.statusColor),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  widget.status ?? '',
                  style: KTextStyle.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => Navigator.pop(context, true),
          child: Card(
            shape: const CircleBorder(),
            color: KColors.colorGray,
            elevation: 0,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, size: 18, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title ?? 'Expense Title',
      style: KTextStyle.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: Color(widget.statusColor),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoRow(String label, String? value,
      {int maxLines = 1, bool isAction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label: ',
              style: KTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: isAction
                ? _buildAttachmentButton(value ?? '-')
                : Text(
              value ?? '-',
              style: KTextStyle.bodyMedium,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(String label) {
    return InkWell(
      onTap: widget.onAttachmentTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: KTextStyle.bodyMedium.copyWith(
              color: KColors.appPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.attachment, size: 16, color: KColors.appPrimary),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    if (_isLoadingAttachments) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text('Attachments: '),
            SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    if (_attachments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No attachments',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attachments:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ..._attachments.map((attachment) {
            final contentDoc = attachment.contentDocument;
            if (contentDoc == null) return const SizedBox.shrink();

            return InkWell(
              onTap: () => _showAttachment(attachment),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: KColors.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(contentDoc.fileExtension),
                      size: 20,
                      color: KColors.appPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        contentDoc.title ?? 'Attachment',
                        style: const TextStyle(
                          color: KColors.appPrimary,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatFileSize(contentDoc.contentSize ?? 0),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildApprovalSection() {
    final bool isPending = widget.status?.toLowerCase() == 'pending';
    final bool isApproved = widget.status?.toLowerCase() == 'approved';
    final bool isRejected = widget.status?.toLowerCase() == 'rejected';

    String approvalTitle;
    String? approvalPerson;
    String? approvalDate;

    if (isPending) {
      approvalTitle = 'Pending at Manager';
      approvalDate = widget.submittedDate;
    } else if (isApproved) {
      approvalTitle = 'Approved by';
      approvalPerson = widget.approvedBy;
      approvalDate = widget.date;
    } else if (isRejected) {
      approvalTitle = 'Rejected by';
      approvalPerson = widget.rejectedBy;
      approvalDate = widget.date;
    } else {
      approvalTitle = 'Approval Status';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          approvalTitle,
          style: KTextStyle.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        if (approvalPerson != null) ...[
          _buildInfoRow('Approver', approvalPerson),
        ],
        if (approvalDate != null) ...[
          _buildInfoRow('Submitted Date', approvalDate),
        ],
        if (isRejected && widget.rejectedBy != null) ...[
          _buildInfoRow('Rejected by', widget.rejectedBy),
        ],
        _buildInfoRow('Manager Remarks', 'Will talk on this', maxLines: 2),
      ],
    );
  }
}