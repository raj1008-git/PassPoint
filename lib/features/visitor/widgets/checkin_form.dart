import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/visitor_repository.dart';
import 'camera_capture.dart';

typedef OnSubmitCallback =
    Future<void> Function({
      required String name,
      required String phone,
      String? email,
      required String toMeet,
      required String purpose,
      required File photoFile,
      File? signatureFile,
      String? departmentId,
      String? departmentName,
      required int numberOfVisitors,
    });

class CheckInForm extends StatefulWidget {
  final OnSubmitCallback onSubmit;

  const CheckInForm({super.key, required this.onSubmit});

  @override
  State<CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _numberOfVisitorsCtrl = TextEditingController(text: '1');
  File? _photoFile;
  File? _signatureFile;
  bool _isSubmitting = false;
  bool _isScanning = false;
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;
  List<String> _peopleInDepartment = [];
  String? _selectedPerson;
  bool _loadingPeople = false;
  Future<List<String>> _loadPeopleInDepartment(String departmentId) async {
    try {
      final repo = UserRepository();
      return await repo.getStaffNamesByDepartment(departmentId);
    } catch (e) {
      devLog(
        'Error loading people in department',
        params: {'error': e.toString()},
      );
      return [];
    }
  }

  void _onDepartmentSelected(String departmentId, String departmentName) async {
    setState(() {
      _selectedDepartmentId = departmentId;
      _selectedDepartmentName = departmentName;
      _selectedPerson = null;
      _peopleInDepartment = [];
      _loadingPeople = true;
    });

    final people = await _loadPeopleInDepartment(departmentId);

    if (!mounted) return;

    setState(() {
      _peopleInDepartment = people;
      _loadingPeople = false;
    });
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  late final Stream<QuerySnapshot> _departmentStreamCached;

  @override
  void initState() {
    super.initState();
    _departmentStreamCached = _departmentsStream();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _purposeCtrl.dispose();
    _numberOfVisitorsCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _scanForExistingVisitor() async {
    devLog('Opening camera for face scanning');

    setState(() => _isScanning = true);

    final file = await Navigator.of(context).push<File?>(
      MaterialPageRoute(
        builder: (_) => CameraCaptureScreen(isFaceScanning: true),
      ),
    );

    if (file == null) {
      setState(() => _isScanning = false);
      return;
    }

    devLog('Face scan photo captured, searching for match');

    try {
      final repo = VisitorRepository();
      final matchedVisitor = await repo.findVisitorByFace(file);

      if (matchedVisitor != null) {
        devLog('Match found!', params: {'name': matchedVisitor.name});

        // Auto-fill the form
        setState(() {
          _nameCtrl.text = matchedVisitor.name;
          _phoneCtrl.text = matchedVisitor.phone;
          _emailCtrl.text = matchedVisitor.email ?? '';
          _purposeCtrl.text = matchedVisitor.purpose;
          _selectedDepartmentId = matchedVisitor.departmentId;
          _selectedDepartmentName = matchedVisitor.departmentName;
          _selectedPerson = matchedVisitor.toMeet;
          _photoFile = file;
          _isScanning = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${matchedVisitor.name}! 👋'),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        devLog('No match found');
        setState(() {
          _photoFile = file;
          _isScanning = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No match found. Please fill in your details.'),
              backgroundColor: AppTheme.info,
            ),
          );
        }
      }
    } catch (e) {
      devLog('Face scan error', params: {'error': e.toString()});
      setState(() => _isScanning = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _openCamera() async {
    devLog('Opening Camera Screen');
    final file = await Navigator.of(
      context,
    ).push<File?>(MaterialPageRoute(builder: (_) => CameraCaptureScreen()));
    if (file != null) {
      setState(() => _photoFile = file);
      devLog('Photo returned from camera', params: {'path': file.path});
    } else {
      devLog('No Photo returned from camera');
    }
  }

  Future<void> _captureSignature() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature first'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    try {
      final Uint8List? data = await _signatureController.toPngBytes();
      if (data == null) return;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data);

      setState(() => _signatureFile = file);
      devLog('Signature captured', params: {'path': file.path});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature captured successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      devLog('Signature capture failed', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture signature: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture a photo'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    if (_signatureFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture your signature'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final numberOfVisitors =
          int.tryParse(_numberOfVisitorsCtrl.text.trim()) ?? 1;

      await widget.onSubmit(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        toMeet: _selectedPerson ?? '',
        purpose: _purposeCtrl.text.trim(),
        photoFile: _photoFile!,
        signatureFile: _signatureFile,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
        numberOfVisitors: numberOfVisitors,
      );
      devLog('Form onSubmit completed successfully');
    } catch (e) {
      devLog('Form submission failed', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
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

  Stream<QuerySnapshot> _departmentsStream() {
    return FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                    maxWidth: isTablet ? 700 : double.infinity,
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
                                color: AppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                size: 32,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Visitor Check-In', style: AppTheme.h3),
                            const SizedBox(height: 8),
                            Text(
                              'Please fill out the form below',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Photo Capture Section - NOW AT TOP
                      _buildPhotoCapture(),

                      const SizedBox(height: 24),

                      // Form Fields
                      if (isTablet) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _nameCtrl,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Enter name'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _phoneCtrl,
                                label: 'Phone Number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) =>
                                    (v == null || v.trim().length < 7)
                                    ? 'Enter valid phone number'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _emailCtrl,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                required: false,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return null;
                                  final re = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  return re.hasMatch(v.trim())
                                      ? null
                                      : 'Enter a valid email';
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _numberOfVisitorsCtrl,
                                label: 'Number of Visitors Accompanied',
                                icon: Icons.group,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Enter number';
                                  }
                                  final num = int.tryParse(v.trim());
                                  if (num == null || num < 1 || num > 50) {
                                    return 'Enter 1-50';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildDepartmentField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPersonField()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _purposeCtrl,
                          label: 'Purpose of Visit',
                          icon: Icons.description_outlined,
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter purpose'
                              : null,
                        ),
                      ] else ...[
                        _buildTextField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneCtrl,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => (v == null || v.trim().length < 7)
                              ? 'Enter valid phone number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          required: false,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final re = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            return re.hasMatch(v.trim())
                                ? null
                                : 'Enter a valid email';
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _numberOfVisitorsCtrl,
                          label: 'Number of Visitors Accompanied',
                          icon: Icons.group,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter number of visitors Accompanied';
                            }
                            final num = int.tryParse(v.trim());
                            if (num == null || num < 1 || num > 50) {
                              return 'Enter between 1-50';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDepartmentField(),
                        const SizedBox(height: 16),
                        _buildPersonField(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _purposeCtrl,
                          label: 'Purpose of Visit',
                          icon: Icons.description_outlined,
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter purpose'
                              : null,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Signature Pad
                      _buildSignaturePad(isTablet),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
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
                              : const Text(
                                  'Submit Check-In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool required = true,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryRed),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.labelLarge),
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
          textInputAction:
              textInputAction ??
              (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
          decoration: InputDecoration(
            hintText: 'Enter ${label.toLowerCase()}',
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

  Widget _buildDepartmentField() {
    return StreamBuilder<QuerySnapshot>(
      stream: _departmentStreamCached,
      builder: (context, snap) {
        if (snap.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 18,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  const Text('Department', style: AppTheme.labelLarge),
                  const Text(' *', style: TextStyle(color: AppTheme.error)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: const Text(
                  'Error loading departments',
                  style: AppTheme.bodySmall,
                ),
              ),
            ],
          );
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 18,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  const Text('Department', style: AppTheme.labelLarge),
                  const Text(' *', style: TextStyle(color: AppTheme.error)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.greyLight.withOpacity(0.5),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ],
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 18,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  const Text('Department', style: AppTheme.labelLarge),
                  const Text(' *', style: TextStyle(color: AppTheme.error)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: const Text(
                  'No departments available',
                  style: AppTheme.bodySmall,
                ),
              ),
            ],
          );
        }

        final items = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return DropdownMenuItem<String>(
            value: d.id,
            child: Text((data['name'] ?? d.id).toString()),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: AppTheme.primaryRed,
                ),
                const SizedBox(width: 8),
                const Text('Department', style: AppTheme.labelLarge),
                const Text(' *', style: TextStyle(color: AppTheme.error)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select department',
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
              onTap: () async {
                FocusScope.of(context).unfocus();
                await Future.delayed(const Duration(milliseconds: 180));
              },
              items: items,
              value: _selectedDepartmentId,
              isExpanded: true,
              onChanged: (val) {
                if (val == null) return;

                final selDoc = docs.firstWhere((d) => d.id == val);
                final data = selDoc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? val).toString();

                _onDepartmentSelected(val, name);

                devLog(
                  'Department selected',
                  params: {'id': val, 'name': name},
                );
              },

              validator: (v) {
                if (v == null || v.isEmpty) return 'Select department';
                return null;
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
            const Icon(
              Icons.people_outline,
              size: 18,
              color: AppTheme.primaryRed,
            ),
            const SizedBox(width: 8),
            const Text('Person to Meet', style: AppTheme.labelLarge),
            const Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('$_selectedDepartmentId-$_selectedPerson'),
          decoration: InputDecoration(
            hintText: _loadingPeople
                ? 'Loading staff...'
                : _peopleInDepartment.isEmpty
                ? 'No staff in department'
                : 'Select person',

            hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
            filled: true,
            fillColor: _selectedDepartmentId == null
                ? AppTheme.greyLight.withOpacity(0.3)
                : AppTheme.greyLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: AppTheme.radiusSmall,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: (_loadingPeople || _peopleInDepartment.isEmpty)
              ? null
              : _peopleInDepartment.map((person) {
                  return DropdownMenuItem<String>(
                    value: person,
                    child: Text(person),
                  );
                }).toList(),

          value: _selectedPerson,
          isExpanded: true,
          onChanged:
              (_selectedDepartmentId == null ||
                  _loadingPeople ||
                  _peopleInDepartment.isEmpty)
              ? null
              : (val) {
                  setState(() => _selectedPerson = val);
                  devLog('Person selected', params: {'person': val});
                },

          validator: (v) {
            if (_selectedDepartmentId == null) return 'Select department first';
            if (v == null || v.isEmpty) return 'Select person to meet';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotoCapture() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _photoFile == null
                ? AppTheme.greyLight.withOpacity(0.3)
                : AppTheme.success.withOpacity(0.05),
            _photoFile == null
                ? AppTheme.greyLight.withOpacity(0.2)
                : AppTheme.success.withOpacity(0.1),
          ],
        ),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: _photoFile == null
              ? AppTheme.greyLight
              : AppTheme.success.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (_photoFile != null) ...[
            ClipRRect(
              borderRadius: AppTheme.radiusSmall,
              child: Image.file(
                _photoFile!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Photo captured successfully',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _photoFile = null);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retake'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
          ] else ...[
            Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: AppTheme.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Photo Required',
              style: AppTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please capture your photo for verification',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Two prominent buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanForExistingVisitor,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.face_retouching_natural, size: 24),
                label: Text(
                  _isScanning
                      ? 'Scanning Face...'
                      : 'Scan Face (Returning Visitor)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.info,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _openCamera,
                icon: const Icon(Icons.camera_alt, size: 24),
                label: const Text(
                  'Take New Photo (First Time Visitor)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryRed,
                  side: const BorderSide(color: AppTheme.primaryRed, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusSmall,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppTheme.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Returning visitor? Use "Scan Face" to auto-fill your details instantly!',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.info,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignaturePad(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.greyLight.withOpacity(0.3),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: _signatureFile == null
              ? AppTheme.greyLight
              : AppTheme.success.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, size: 18, color: AppTheme.primaryRed),
              const SizedBox(width: 8),
              const Text('Signature', style: AppTheme.labelLarge),
              const Text(' *', style: TextStyle(color: AppTheme.error)),
            ],
          ),
          const SizedBox(height: 12),
          if (_signatureFile != null) ...[
            ClipRRect(
              borderRadius: AppTheme.radiusSmall,
              child: Image.file(
                _signatureFile!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain,
                color: AppTheme.white,
                colorBlendMode: BlendMode.darken,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Signature captured successfully',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _signatureFile = null;
                      _signatureController.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Please sign below',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: AppTheme.radiusSmall,
                border: Border.all(color: AppTheme.greyLight, width: 1),
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: AppTheme.white,
              ),
            ),
            const SizedBox(height: 12),
            isTablet
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _signatureController.clear(),
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _captureSignature,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Capture Signature'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusSmall,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _captureSignature,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Capture Signature'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _signatureController.clear(),
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
          ],
        ],
      ),
    );
  }
}
