import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/branch_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/user_repository.dart';

class StaffProductCheckInScreen extends StatefulWidget {
  const StaffProductCheckInScreen({Key? key}) : super(key: key);

  @override
  State<StaffProductCheckInScreen> createState() =>
      _StaffProductCheckInScreenState();
}

class _StaffProductCheckInScreenState extends State<StaffProductCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receivedLetterNumberCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();

  DateTime? _receivedLetterDate;
  bool _isSubmitting = false;

  // Staff info (auto-filled)
  String? _staffUid;
  String? _staffName;
  String? _staffBranch;
  String? _staffDepartment;
  bool _isHQStaff = false;

  // Target selection
  String _targetType = 'branch'; // "branch" or "department"
  String? _selectedTargetBranchId;
  String? _selectedTargetBranchName;
  String? _selectedTargetDepartmentId;
  String? _selectedTargetDepartmentName;
  String? _selectedTargetStaff;
  bool _loadingStaff = false;
  List<String> _availableStaff = [];

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
  }

  @override
  void dispose() {
    _receivedLetterNumberCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStaffInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _staffUid = user.uid;
          _staffName = data['name'] as String?;
          _staffBranch = data['branchName'] as String?;
          _staffDepartment = data['departmentName'] as String?;
          _isHQStaff = _staffBranch?.toUpperCase() == 'KAMALADI';

          // Branch staff can only send to HQ departments
          if (!_isHQStaff) {
            _targetType = 'department';
          }
        });

        devLog(
          'Staff info loaded for product check-in',
          params: {
            'name': _staffName,
            'branch': _staffBranch,
            'isHQ': _isHQStaff,
          },
        );
      }
    } catch (e) {
      devLog('Error loading staff info', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.info,
              onPrimary: AppTheme.white,
              onSurface: AppTheme.dark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _receivedLetterDate = picked);
    }
  }

  Future<void> _onTargetBranchSelected(
    String branchId,
    String branchName,
  ) async {
    setState(() {
      _selectedTargetBranchId = branchId;
      _selectedTargetBranchName = branchName;
      _selectedTargetStaff = null;
      _availableStaff = [];
      _loadingStaff = true;
    });

    try {
      final repo = ProductRepository();
      final staff = await repo.getStaffByBranch(branchName);
      if (mounted) {
        setState(() {
          _availableStaff = staff.map((s) => s['name']!).toList();
          _loadingStaff = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingStaff = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading staff: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _onTargetDepartmentSelected(
    String deptId,
    String deptName,
  ) async {
    setState(() {
      _selectedTargetDepartmentId = deptId;
      _selectedTargetDepartmentName = deptName;
      _selectedTargetStaff = null;
      _availableStaff = [];
      _loadingStaff = true;
    });

    try {
      final repo = UserRepository();
      final staff = await repo.getStaffNamesByDepartment(deptId);
      if (mounted) {
        setState(() {
          _availableStaff = staff;
          _loadingStaff = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingStaff = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading staff: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_receivedLetterDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select received letter date'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_targetType == 'branch' && _selectedTargetBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select target branch'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_targetType == 'department' && _selectedTargetDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select target department'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_selectedTargetStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select target staff member'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ProductRepository();
      await repo.createStaffProduct(
        staffUid: _staffUid!,
        staffName: _staffName!,
        staffBranch: _staffBranch!,
        staffDepartment: _staffDepartment,
        receivedLetterNumber: _receivedLetterNumberCtrl.text.trim(),
        receivedLetterDate: _receivedLetterDate!,
        subject: _subjectCtrl.text.trim(),
        targetType: _targetType,
        targetBranchId: _selectedTargetBranchId,
        targetBranchName: _selectedTargetBranchName,
        targetDepartmentId: _selectedTargetDepartmentId,
        targetDepartmentName: _selectedTargetDepartmentName,
        targetStaffName: _selectedTargetStaff!,
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
                Text('Product Registered'),
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
                if (_targetType == 'branch') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flash_on,
                          color: AppTheme.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Direct delivery to $_selectedTargetBranchName - $_selectedTargetStaff',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
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
                            'Receptionist will forward to $_selectedTargetDepartmentName',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.info,
                  foregroundColor: AppTheme.white,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      devLog('Product check-in failed', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in failed: $e'),
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
          'Staff Product Check-In',
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
                                  color: AppTheme.success,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  size: 32,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Inter-Branch Product Transfer',
                                style: AppTheme.h3,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Send product to another branch or department',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Sender Info (Auto-filled)
                        _buildSectionHeader('Sender Information (You)'),
                        const SizedBox(height: 16),
                        _buildInfoCard(),

                        const SizedBox(height: 24),

                        // Product Details
                        _buildSectionHeader('Product Details'),
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
                          onTap: () => _selectDate(context),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _subjectCtrl,
                          label: 'Subject / Description',
                          icon: Icons.description,
                          hint: 'Brief description',
                          maxLines: 3,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // Target Selection
                        _buildSectionHeader('Delivery Target'),
                        const SizedBox(height: 16),

                        // Target Type Toggle (only for HQ staff)
                        if (_isHQStaff) ...[
                          _buildTargetTypeToggle(),
                          const SizedBox(height: 16),
                        ],

                        // Target Branch or Department
                        if (_targetType == 'branch')
                          _buildBranchDropdown()
                        else
                          _buildDepartmentDropdown(),

                        const SizedBox(height: 16),

                        // Target Staff
                        _buildStaffDropdown(),

                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.success,
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
                                        'Submit Product Transfer',
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
            color: AppTheme.success,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTheme.h3.copyWith(fontSize: 18)),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: AppTheme.success.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          _buildInfoRow('Name', _staffName ?? 'Loading...'),
          const SizedBox(height: 8),
          _buildInfoRow('Branch', _staffBranch ?? 'Loading...'),
          if (_staffDepartment != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Department', _staffDepartment!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.success),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.labelLarge),
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
            Icon(icon, size: 18, color: AppTheme.success),
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
                  color: AppTheme.success,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.route, size: 18, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Send To', style: AppTheme.labelLarge),
            Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.greyLight.withOpacity(0.5),
            borderRadius: AppTheme.radiusSmall,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _targetType = 'branch'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _targetType == 'branch'
                          ? AppTheme.success
                          : Colors.transparent,
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: Text(
                      'Branch Staff',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _targetType == 'branch'
                            ? AppTheme.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _targetType = 'department'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _targetType == 'department'
                          ? AppTheme.success
                          : Colors.transparent,
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: Text(
                      'HQ Department',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _targetType == 'department'
                            ? AppTheme.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return FutureBuilder(
      future: BranchRepository().getBranches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        // Filter out HQ and current branch
        final branches = snapshot.data!
            .where((b) => !b.isHeadquarter && b.name != _staffBranch)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_city, size: 18, color: AppTheme.success),
                SizedBox(width: 8),
                Text('Target Branch', style: AppTheme.labelLarge),
                Text(' *', style: TextStyle(color: AppTheme.error)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select branch',
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
              value: _selectedTargetBranchId,
              isExpanded: true,
              items: branches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch.id,
                  child: Text(branch.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final selected = branches.firstWhere((b) => b.id == val);
                  _onTargetBranchSelected(val, selected.name);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDepartmentDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('departments')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading departments');
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final docs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: AppTheme.success,
                ),
                SizedBox(width: 8),
                Text('Target Department (HQ)', style: AppTheme.labelLarge),
                Text(' *', style: TextStyle(color: AppTheme.error)),
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
              value: _selectedTargetDepartmentId,
              isExpanded: true,
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
                  _onTargetDepartmentSelected(val, data['name'] ?? val);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStaffDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.person_outline, size: 18, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Target Staff Member', style: AppTheme.labelLarge),
            Text(' *', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: _loadingStaff
                ? 'Loading staff...'
                : _availableStaff.isEmpty
                ? 'Select ${_targetType == "branch" ? "branch" : "department"} first'
                : 'Select staff',
            hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
            filled: true,
            fillColor: _availableStaff.isEmpty
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
          value: _selectedTargetStaff,
          isExpanded: true,
          items: _availableStaff.isEmpty
              ? null
              : _availableStaff.map((staff) {
                  return DropdownMenuItem<String>(
                    value: staff,
                    child: Text(staff),
                  );
                }).toList(),
          onChanged: _loadingStaff || _availableStaff.isEmpty
              ? null
              : (val) => setState(() => _selectedTargetStaff = val),
        ),
      ],
    );
  }
}
