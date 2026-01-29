import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../visitor/widgets/camera_capture.dart';

class ProductCheckInScreen extends StatefulWidget {
  const ProductCheckInScreen({Key? key}) : super(key: key);

  @override
  State<ProductCheckInScreen> createState() => _ProductCheckInScreenState();
}

class _ProductCheckInScreenState extends State<ProductCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regNumberCtrl = TextEditingController();
  final _receivedLetterNumberCtrl = TextEditingController();
  final _senderOfficeCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _deliveryPersonNameCtrl = TextEditingController();
  final _deliveryPersonContactCtrl = TextEditingController();

  DateTime? _registrationDate;
  DateTime? _receivedLetterDate;
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;
  String? _selectedPerson;
  File? _productPhoto;
  bool _isSubmitting = false;
  bool _loadingPeople = false;
  List<String> _peopleInDepartment = [];

  @override
  void dispose() {
    _regNumberCtrl.dispose();
    _receivedLetterNumberCtrl.dispose();
    _senderOfficeCtrl.dispose();
    _subjectCtrl.dispose();
    _deliveryPersonNameCtrl.dispose();
    _deliveryPersonContactCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isRegistrationDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryRed,
              onPrimary: AppTheme.white,
              onSurface: AppTheme.dark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isRegistrationDate) {
          _registrationDate = picked;
        } else {
          _receivedLetterDate = picked;
        }
      });
    }
  }

  Future<void> _capturePhoto() async {
    final file = await Navigator.of(context).push<File?>(
      MaterialPageRoute(
        builder: (_) =>
            const CameraCaptureScreen(preferredLens: CameraLensDirection.back),
      ),
    );
    if (file != null) {
      setState(() => _productPhoto = file);
    }
  }

  Future<void> _onDepartmentSelected(String deptId, String deptName) async {
    setState(() {
      _selectedDepartmentId = deptId;
      _selectedDepartmentName = deptName;
      _selectedPerson = null;
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
    if (!_formKey.currentState!.validate()) return;

    if (_registrationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select registration date'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_receivedLetterDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select received letter date'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ProductRepository();
      await repo.createProduct(
        registrationNumber: _regNumberCtrl.text.trim(),
        registrationDate: _registrationDate!,
        receivedLetterNumber: _receivedLetterNumberCtrl.text.trim(),
        receivedLetterDate: _receivedLetterDate!,
        senderOfficeName: _senderOfficeCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        targetDepartmentId: _selectedDepartmentId!,
        targetDepartmentName: _selectedDepartmentName!,
        targetPersonName: _selectedPerson!,
        productPhoto: _productPhoto,
        deliveryPersonName: _deliveryPersonNameCtrl.text.trim().isEmpty
            ? null
            : _deliveryPersonNameCtrl.text.trim(),
        deliveryPersonContact: _deliveryPersonContactCtrl.text.trim().isEmpty
            ? null
            : _deliveryPersonContactCtrl.text.trim(),
      );

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.success, size: 32),
                SizedBox(width: 12),
                Text('Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product has been registered successfully!',
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Registration No: ${_regNumberCtrl.text}',
                  style: AppTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Target: ${_selectedDepartmentName} - $_selectedPerson',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.info,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reception will verify and forward to the department.',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: AppTheme.white,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      devLog('Product submission failed', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Product/Parcel Check-In',
          style: TextStyle(color: AppTheme.dark),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          return AbsorbPointer(
            absorbing: _isSubmitting,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 32 : 20),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 800 : double.infinity,
                    ),
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: AppTheme.radiusLarge,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.info,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  size: 32,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Product/Parcel Registration',
                                style: AppTheme.h3,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Fill in the delivery details',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Registration Details Section
                        _buildSectionHeader('Registration Details'),
                        const SizedBox(height: 16),

                        if (isTablet) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _regNumberCtrl,
                                  label: 'Registration Number (Darta Number)',
                                  icon: Icons.numbers,
                                  hint: 'e.g., 1900',
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDateField(
                                  label: 'Registration Date',
                                  icon: Icons.calendar_today,
                                  date: _registrationDate,
                                  onTap: () => _selectDate(context, true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _receivedLetterNumberCtrl,
                                  label: 'Received Letter Number',
                                  icon: Icons.mail_outline,
                                  hint: 'e.g., 20',
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDateField(
                                  label: 'Received Letter Date',
                                  icon: Icons.calendar_today,
                                  date: _receivedLetterDate,
                                  onTap: () => _selectDate(context, false),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildTextField(
                            controller: _regNumberCtrl,
                            label: 'Registration Number (Darta Number)',
                            icon: Icons.numbers,
                            hint: 'e.g., 1900',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildDateField(
                            label: 'Registration Date',
                            icon: Icons.calendar_today,
                            date: _registrationDate,
                            onTap: () => _selectDate(context, true),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _receivedLetterNumberCtrl,
                            label: 'Received Letter Number',
                            icon: Icons.mail_outline,
                            hint: 'e.g., 20',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildDateField(
                            label: 'Received Letter Date',
                            icon: Icons.calendar_today,
                            date: _receivedLetterDate,
                            onTap: () => _selectDate(context, false),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Sender & Product Details
                        _buildSectionHeader('Sender & Product Details'),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _senderOfficeCtrl,
                          label: 'Sender Office Name',
                          icon: Icons.business,
                          hint: 'e.g., Dhangadi Municipality',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _subjectCtrl,
                          label: 'Subject / Description',
                          icon: Icons.description,
                          hint: 'Brief description of the product/parcel',
                          maxLines: 3,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // Target Department & Person
                        _buildSectionHeader('Delivery Target'),
                        const SizedBox(height: 16),

                        _buildDepartmentDropdown(),
                        const SizedBox(height: 16),
                        _buildPersonDropdown(),

                        const SizedBox(height: 24),

                        // Optional: Product Photo
                        _buildSectionHeader('Product Photo'),
                        const SizedBox(height: 16),
                        _buildPhotoSection(),

                        const SizedBox(height: 24),

                        // Optional: Delivery Person Details
                        _buildSectionHeader('Delivery Person Details'),
                        const SizedBox(height: 16),

                        if (isTablet) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _deliveryPersonNameCtrl,
                                  label: 'Delivery Person Name',
                                  icon: Icons.person_outline,
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _deliveryPersonContactCtrl,
                                  label: 'Contact Number',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildTextField(
                            controller: _deliveryPersonNameCtrl,
                            label: 'Delivery Person Name',
                            icon: Icons.person_outline,
                            required: false,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _deliveryPersonContactCtrl,
                            label: 'Contact Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            required: false,
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.info,
                              foregroundColor: AppTheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.radiusMedium,
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send),
                                      SizedBox(width: 12),
                                      Text(
                                        'Submit Product Check-In',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.info,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTheme.h3.copyWith(fontSize: 18)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.info),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: AppTheme.labelLarge)),
            if (required)
              const Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
            filled: true,
            fillColor: AppTheme.greyLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: AppTheme.radiusSmall,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.info),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.labelLarge),
            const Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withOpacity(0.5),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date == null
                        ? 'Select date'
                        : DateFormat('yyyy-MM-dd').format(date),
                    style: TextStyle(
                      color: date == null
                          ? AppTheme.grey.withOpacity(0.5)
                          : AppTheme.dark,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppTheme.info,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
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
                return DropdownMenuItem(
                  value: doc.id,
                  child: Text(data['name'] ?? doc.id),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final doc = docs.firstWhere((d) => d.id == val);
                  final data = doc.data() as Map<String, dynamic>;
                  _onDepartmentSelected(val, data['name'] ?? val);
                }
              },
              validator: (v) => v == null ? 'Select department' : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: AppTheme.info),
            const SizedBox(width: 8),
            const Text('Person to Receive', style: AppTheme.labelLarge),
            const Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: _loadingPeople
                ? 'Loading staff...'
                : _peopleInDepartment.isEmpty
                ? 'No staff available'
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
          value: _selectedPerson,
          items: _peopleInDepartment.isEmpty
              ? null
              : _peopleInDepartment.map((person) {
                  return DropdownMenuItem(value: person, child: Text(person));
                }).toList(),
          onChanged: _selectedDepartmentId == null || _loadingPeople
              ? null
              : (val) => setState(() => _selectedPerson = val),
          validator: (v) {
            if (_selectedDepartmentId == null) return 'Select department first';
            if (v == null) return 'Select person';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.greyLight.withOpacity(0.3),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: _productPhoto == null
              ? AppTheme.greyLight
              : AppTheme.success.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: _productPhoto == null
          ? Column(
              children: [
                Icon(Icons.camera_alt_outlined, size: 48, color: AppTheme.grey),
                const SizedBox(height: 16),
                const Text('No photo captured', style: AppTheme.labelLarge),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _capturePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.info,
                    foregroundColor: AppTheme.white,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ClipRRect(
                  borderRadius: AppTheme.radiusSmall,
                  child: Image.file(
                    _productPhoto!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.success),
                    const SizedBox(width: 8),
                    const Text('Photo captured', style: AppTheme.labelLarge),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: _capturePhoto,
                      child: const Text('Retake'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
