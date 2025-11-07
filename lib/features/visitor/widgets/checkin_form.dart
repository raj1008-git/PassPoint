import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_point/core/utils/dev.log.dart';
import 'package:pass_point/features/visitor/widgets/camera_capture.dart';

typedef OnSubmitCallback =
    Future<void> Function({
      required String name,
      required String phone,
      String? email,
      required String toMeet,
      required String purpose,
      required File photoFile,
      // NEW: optional department fields
      String? departmentId,
      String? departmentName,
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
  final _toMeetCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  File? _photoFile;
  bool _isSubmitting = false;

  // department selection state
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;

  // Manual department controller (used when fallback shown)
  final _manualDeptCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _toMeetCtrl.dispose();
    _purposeCtrl.dispose();
    _manualDeptCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    devLog('Opening Camera Screen');
    final file = await Navigator.of(
      context,
    ).push<File?>(MaterialPageRoute(builder: (_) => CameraCaptureScreen()));
    if (file != null) {
      setState(() {
        _photoFile = file;
      });
      devLog('Photo returned from camera', params: {'path': file.path});
    } else {
      devLog('No Photo returned from camera');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please capture a photo')));
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    // If manual department was used, ensure departmentName is set
    if ((_selectedDepartmentName == null ||
            _selectedDepartmentName!.trim().isEmpty) &&
        (_manualDeptCtrl.text.trim().isNotEmpty)) {
      _selectedDepartmentName = _manualDeptCtrl.text.trim();
      _selectedDepartmentId = null;
    }

    try {
      await widget.onSubmit(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        toMeet: _toMeetCtrl.text.trim(),
        purpose: _purposeCtrl.text.trim(),
        photoFile: _photoFile!,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
      );
      devLog('Form onSubmit completed successfully');
    } catch (e) {
      devLog('Form submission failed', params: {'error': e.toString()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Stream of departments from Firestore: collection 'departments'
  Stream<QuerySnapshot> _departmentsStream() {
    return FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isSubmitting,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.trim().length < 7)
                  ? 'Enter valid phone number'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final re = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                return re.hasMatch(v.trim()) ? null : 'Enter a valid Email';
              },
            ),
            const SizedBox(height: 12),

            // Departments stream with fallback to manual entry.
            StreamBuilder<QuerySnapshot>(
              stream: _departmentsStream(),
              builder: (context, snap) {
                if (snap.hasError) {
                  devLog(
                    'Departments stream error',
                    params: {'error': snap.error},
                  );
                  // Fallback: manual entry
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _manualDeptCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Department (enter manually)',
                        ),
                        validator: (v) {
                          // If no selection and no manual entry -> error
                          if ((_selectedDepartmentId == null ||
                                  _selectedDepartmentId!.isEmpty) &&
                              (v == null || v.trim().isEmpty))
                            return 'Enter department';
                          return null;
                        },
                        onChanged: (v) {
                          _selectedDepartmentId = null;
                          _selectedDepartmentName = v.trim().isEmpty
                              ? null
                              : v.trim();
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tip: Add departments in Firestore under collection "departments" with a `name` field.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }

                if (snap.connectionState == ConnectionState.waiting) {
                  devLog('Departments stream waiting...');
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  );
                }

                final docs = snap.data?.docs ?? [];
                devLog(
                  'Departments snapshot count',
                  params: {'count': docs.length},
                );

                if (docs.isEmpty) {
                  // No departments present — show manual entry fallback
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('No departments available.'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _manualDeptCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Department (enter manually)',
                        ),
                        validator: (v) {
                          if ((_selectedDepartmentId == null ||
                                  _selectedDepartmentId!.isEmpty) &&
                              (v == null || v.trim().isEmpty))
                            return 'Enter department';
                          return null;
                        },
                        onChanged: (v) {
                          _selectedDepartmentId = null;
                          _selectedDepartmentName = v.trim().isEmpty
                              ? null
                              : v.trim();
                        },
                      ),
                    ],
                  );
                }

                // Build dropdown from documents
                final items = docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: d.id,
                    child: Text((data['name'] ?? d.id).toString()),
                  );
                }).toList();

                // If previously chosen deptId no longer exists, reset selection
                if (_selectedDepartmentId != null &&
                    !docs.any((d) => d.id == _selectedDepartmentId)) {
                  _selectedDepartmentId = null;
                  _selectedDepartmentName = null;
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: items,
                  value: _selectedDepartmentId,
                  onChanged: (val) {
                    final selDoc = docs.firstWhere((d) => d.id == val);
                    final name =
                        (selDoc.data() as Map<String, dynamic>)['name']
                            ?.toString() ??
                        val;
                    setState(() {
                      _selectedDepartmentId = val;
                      _selectedDepartmentName = name;
                      _manualDeptCtrl.text = '';
                    });
                    devLog(
                      'Department selected',
                      params: {'id': val, 'name': name},
                    );
                  },
                  validator: (v) {
                    // Accept either a dropdown selection or manual department name
                    if ((_selectedDepartmentName != null) &&
                        (_selectedDepartmentName!.trim().isNotEmpty))
                      return null;
                    if (v == null || v.isEmpty) return 'Select department';
                    return null;
                  },
                );
              },
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _toMeetCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Person to meet (name)',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter who to meet' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purposeCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Purpose of visit'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter purpose' : null,
            ),
            const SizedBox(height: 16),
            // Photo Capture Row
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _openCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Photo'),
                ),
                const SizedBox(width: 12),
                if (_photoFile != null)
                  Expanded(
                    child: Text(
                      'Photo ready: ${_photoFile!.path.split('/').last}', // Shows just the filename
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Expanded(child: Text('No photo captured')),
              ],
            ),
            const SizedBox(height: 20),
            // Submission Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Check-In'),
            ),
          ],
        ),
      ),
    );
  }
}
