// views/expense/attachment_viewer.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:time_log/controllers/expense_controller.dart';
import 'package:time_log/utils/constants/k_colors.dart';

class AttachmentViewerDialog extends StatefulWidget {
  final String expenseId;
  final String contentDocumentId;
  final String title;
  final String? fileExtension;
  final ExpenseController controller;

  const AttachmentViewerDialog({
    super.key,
    required this.expenseId,
    required this.contentDocumentId,
    required this.title,
    this.fileExtension,
    required this.controller,
  });

  @override
  State<AttachmentViewerDialog> createState() => _AttachmentViewerDialogState();
}

class _AttachmentViewerDialogState extends State<AttachmentViewerDialog> {
  bool _isLoading = true;
  String? _base64Data;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttachment();
  }

  Future<void> _loadAttachment() async {
    setState(() => _isLoading = true);

    try {
      final result = await widget.controller.getFileData(widget.contentDocumentId);

      if (result['success'] == true) {
        setState(() {
          _base64Data = result['base64Data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load attachment';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading attachment: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading attachment...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: KColors.appPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    if (_base64Data != null) {
      final fileExtension = widget.fileExtension?.toLowerCase() ?? '';

      // Check if it's an image
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileExtension)) {
        return _buildImagePreview();
      }

      // For PDF and other documents
      return _buildDocumentPreview();
    }

    return const Center(
      child: Text('No data available'),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(_base64Data!),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      const Text('Failed to load image'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${widget.fileExtension?.toUpperCase() ?? 'File'} • ${_formatFileSize(0)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: KColors.appPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDocumentPreview() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getFileIcon(widget.fileExtension),
                  size: 64,
                  color: KColors.appPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.fileExtension?.toUpperCase() ?? 'Document'} File',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Size: ${_formatFileSize(0)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preview not available for this file type',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _downloadFile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.appPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
            minimumSize: const Size(double.infinity, 40),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getFileIcon(String? extension) {
    final ext = extension?.toLowerCase() ?? '';
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_fields;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _downloadFile() {
    // TODO: Implement download functionality
    // You can use path_provider and share packages to save and share the file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}