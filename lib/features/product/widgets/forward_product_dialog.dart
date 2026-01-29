import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/user_repository.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../model/product_model.dart';

class ForwardProductDialog extends StatefulWidget {
  final ProductModel product;
  final String currentStaffName;
  final String currentDepartment;

  const ForwardProductDialog({
    Key? key,
    required this.product,
    required this.currentStaffName,
    required this.currentDepartment,
  }) : super(key: key);

  @override
  State<ForwardProductDialog> createState() => _ForwardProductDialogState();
}

class _ForwardProductDialogState extends State<ForwardProductDialog> {
  final _feedbackCtrl = TextEditingController();
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;
  String? _selectedPersonName;
  List<String> _peopleInDepartment = [];
  bool _loadingPeople = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDepartmentSelected(String deptId, String deptName) async {
    setState(() {
      _selectedDepartmentId = deptId;
      _selectedDepartmentName = deptName;
      _selectedPersonName = null;
      _peopleInDepartment = [];
      _loadingPeople = true;
    });

    try {
      final repo = UserRepository();
      final people = await repo.getStaffNamesByDepartment(deptId);

      if (mounted) {
        setState(() {
          _peopleInDepartment = people;
          _loadingPeople = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingPeople = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_selectedPersonName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a person'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_feedbackCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback/reason for forwarding'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      context.read<ProductBloc>().add(
        ForwardProduct(
          productId: widget.product.id,
          fromStaffName: widget.currentStaffName,
          fromDepartment: widget.currentDepartment,
          toDepartmentId: _selectedDepartmentId!,
          toDepartmentName: _selectedDepartmentName!,
          toPersonName: _selectedPersonName!,
          feedback: _feedbackCtrl.text.trim(),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Forward failed: $e'),
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
                        color: AppTheme.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.forward,
                        color: AppTheme.info,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text('Forward Product', style: AppTheme.h3),
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

                // Department Selection
                _buildDepartmentField(),

                const SizedBox(height: 16),

                // Person Selection
                _buildPersonField(),

                const SizedBox(height: 16),

                // Feedback (Required)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.comment,
                          size: 18,
                          color: AppTheme.info,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Feedback / Reason',
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
                        hintText:
                            'Explain why you are forwarding this product...',
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
                          backgroundColor: AppTheme.info,
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
                            : const Text('Forward Product'),
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

  Widget _buildDepartmentField() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('departments')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: AppTheme.info,
                ),
                const SizedBox(width: 8),
                const Text('Target Department', style: AppTheme.labelLarge),
                const Text(' *', style: TextStyle(color: AppTheme.error)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select department',
                filled: true,
                fillColor: AppTheme.greyLight.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: AppTheme.radiusSmall,
                  borderSide: BorderSide.none,
                ),
              ),
              value: _selectedDepartmentId,
              items: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(data['name'] ?? doc.id),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final selected = docs.firstWhere((d) => d.id == val);
                  final data = selected.data() as Map<String, dynamic>;
                  _onDepartmentSelected(val, data['name'] ?? val);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: AppTheme.info),
            const SizedBox(width: 8),
            const Text('Target Person', style: AppTheme.labelLarge),
            const Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: _loadingPeople
                ? 'Loading staff...'
                : _peopleInDepartment.isEmpty
                ? 'Select department first'
                : 'Select person',
            filled: true,
            fillColor: _selectedDepartmentId == null
                ? AppTheme.greyLight.withOpacity(0.3)
                : AppTheme.greyLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: AppTheme.radiusSmall,
              borderSide: BorderSide.none,
            ),
          ),
          value: _selectedPersonName,
          items: _peopleInDepartment.map((person) {
            return DropdownMenuItem<String>(value: person, child: Text(person));
          }).toList(),
          onChanged:
              (_selectedDepartmentId == null ||
                  _loadingPeople ||
                  _peopleInDepartment.isEmpty)
              ? null
              : (val) => setState(() => _selectedPersonName = val),
        ),
      ],
    );
  }
}
