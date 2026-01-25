import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/services/staff_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class StaffRegistrationScreen extends StatefulWidget {
  const StaffRegistrationScreen({super.key});

  @override
  State<StaffRegistrationScreen> createState() =>
      _StaffRegistrationScreenState();
}

class _StaffRegistrationScreenState extends State<StaffRegistrationScreen> {
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;
  List<String> _peopleInDepartment = [];
  String? _selectedPersonName;
  bool _isRegistering = false;

  Map<String, dynamic>? _microsoftData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_microsoftData == null) {
      _microsoftData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    }
  }

  Future<void> _register() async {
    if (_selectedDepartmentId == null || _selectedPersonName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both department and your name'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final success = await StaffService.registerStaff(
        microsoftId: _microsoftData!['microsoftId'],
        email: _microsoftData!['email'],
        name: _selectedPersonName!,
        departmentId: _selectedDepartmentId!,
        departmentName: _selectedDepartmentName!,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        setState(() => _isRegistering = false);
        return;
      }

      // Get the newly created staff document
      final staffData = await StaffService.getStaffByEmail(
        _microsoftData!['email'],
      );

      if (staffData == null) {
        throw Exception('Failed to retrieve staff data after registration');
      }

      // Save login state
      await StaffService.setStaffLoggedIn(
        true,
        email: _microsoftData!['email'],
        name: _selectedPersonName!,
        userId: staffData['id'],
        departmentId: _selectedDepartmentId!,
        departmentName: _selectedDepartmentName!,
        accessToken: _microsoftData!['accessToken'],
      );

      devLog('Staff registered and logged in successfully');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome, $_selectedPersonName! Registration successful.',
            ),
            backgroundColor: AppTheme.success,
          ),
        );

        // Navigate to staff dashboard
        Navigator.of(context).pushReplacementNamed('/staff-dashboard');
      }
    } catch (e) {
      devLog('Registration error', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
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
    if (_microsoftData == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(child: Text('Error: No registration data found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final maxWidth = isTablet ? 600.0 : constraints.maxWidth * 0.9;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 20,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: maxWidth,
                          padding: EdgeInsets.all(isTablet ? 48 : 32),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: AppTheme.radiusLarge,
                            boxShadow: AppTheme.elevatedShadow,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.info,
                                        borderRadius: AppTheme.radiusMedium,
                                      ),
                                      child: const Icon(
                                        Icons.person_add,
                                        color: AppTheme.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Complete Registration',
                                      style: AppTheme.h2,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Signed in as: ${_microsoftData!['email']}',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Info Box
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.info.withOpacity(0.1),
                                  borderRadius: AppTheme.radiusSmall,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppTheme.info,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Please select your department and name to complete registration.',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Department Selection
                              _buildDepartmentField(),

                              const SizedBox(height: 20),

                              // Name Selection
                              _buildNameField(),

                              const SizedBox(height: 32),

                              // Register Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isRegistering ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.info,
                                    foregroundColor: AppTheme.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppTheme.radiusSmall,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isRegistering
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppTheme.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Complete Registration',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildDepartmentField() {
    return StreamBuilder<QuerySnapshot>(
      stream: _departmentsStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _buildErrorField('Error loading departments');
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return _buildLoadingField('Department');
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildErrorField('No departments available');
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
                  color: AppTheme.info,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Your Department',
                  style: AppTheme.labelLarge,
                ),
                const Text(' *', style: TextStyle(color: AppTheme.error)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Choose your department',
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
              items: items,
              value: _selectedDepartmentId,
              isExpanded: true,
              onChanged: (val) {
                if (val == null) return;

                final selDoc = docs.firstWhere((d) => d.id == val);
                final data = selDoc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? val).toString();
                final people = (data['people'] as List?)?.cast<String>() ?? [];

                setState(() {
                  _selectedDepartmentId = val;
                  _selectedDepartmentName = name;
                  _peopleInDepartment = people;
                  _selectedPersonName = null;
                });

                devLog(
                  'Department selected',
                  params: {'id': val, 'name': name, 'people': people},
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: AppTheme.info),
            const SizedBox(width: 8),
            const Text('Select Your Name', style: AppTheme.labelLarge),
            const Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: _selectedDepartmentId == null
                ? 'Select department first'
                : _peopleInDepartment.isEmpty
                ? 'No people in department'
                : 'Choose your name',
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
          items: _peopleInDepartment.isEmpty
              ? null
              : _peopleInDepartment.map((person) {
                  return DropdownMenuItem<String>(
                    value: person,
                    child: Text(person),
                  );
                }).toList(),
          value: _selectedPersonName,
          isExpanded: true,
          onChanged:
              _selectedDepartmentId == null || _peopleInDepartment.isEmpty
              ? null
              : (val) {
                  setState(() => _selectedPersonName = val);
                  devLog('Name selected', params: {'name': val});
                },
        ),
      ],
    );
  }

  Widget _buildErrorField(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: AppTheme.radiusSmall,
      ),
      child: Text(message, style: AppTheme.bodySmall),
    );
  }

  Widget _buildLoadingField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: AppTheme.labelLarge),
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
}
