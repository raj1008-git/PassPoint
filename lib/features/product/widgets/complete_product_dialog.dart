import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signature/signature.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/product_repository.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../model/product_model.dart';

class CompleteProductDialog extends StatefulWidget {
  final ProductModel product;
  final String staffName;
  final String department;
  final bool isReceptionist; // NEW: Receptionist intervention capability

  const CompleteProductDialog({
    Key? key,
    required this.product,
    required this.staffName,
    required this.department,
    this.isReceptionist = false,
  }) : super(key: key);

  @override
  State<CompleteProductDialog> createState() => _CompleteProductDialogState();
}

class _CompleteProductDialogState extends State<CompleteProductDialog> {
  final _feedbackCtrl = TextEditingController();
  final _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: AppTheme.dark,
    exportBackgroundColor: Colors.white,
  );
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_feedbackCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your signature'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Capture signature
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null)
        throw Exception('Failed to capture signature');

      // Save to temp file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(signatureBytes);

      // Upload signature
      final repo = ProductRepository();
      final signatureUrl = await repo.uploadSignature(tempFile);

      // Complete product
      if (mounted) {
        context.read<ProductBloc>().add(
          CompleteProduct(
            productId: widget.product.id,
            staffName: widget.staffName,
            department: widget.department,
            feedback: _feedbackCtrl.text.trim(),
            signatureUrl: signatureUrl,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Completion failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.done_all,
                        color: AppTheme.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mark as Completed', style: AppTheme.h3),
                          if (widget.isReceptionist)
                            Text(
                              'Receptionist Intervention',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Product Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.greyLight.withOpacity(0.3),
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registration #${widget.product.registrationNumber}',
                        style: AppTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.subject,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Feedback (Required)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.comment,
                          size: 18,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Feedback / Remarks',
                          style: AppTheme.labelLarge,
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: widget.isReceptionist
                            ? 'Provide reason for intervention and completion...'
                            : 'Confirm product received in good condition...',
                        hintStyle: TextStyle(
                          color: AppTheme.grey.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.greyLight.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.radiusSmall,
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Signature (Required)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.edit,
                          size: 18,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 8),
                        const Text('Signature', style: AppTheme.labelLarge),
                        const Text(
                          ' *',
                          style: TextStyle(color: AppTheme.error),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _signatureController.clear(),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.greyLight, width: 2),
                        borderRadius: AppTheme.radiusSmall,
                        color: Colors.white,
                      ),
                      child: Signature(
                        controller: _signatureController,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign above to confirm receipt',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Warning (if receptionist)
                if (widget.isReceptionist)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: AppTheme.radiusSmall,
                      border: Border.all(
                        color: AppTheme.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: AppTheme.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Receptionist intervention - This action will finalize the product delivery workflow.',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (widget.isReceptionist) const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.greyLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusSmall,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusSmall,
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Mark as Completed'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
