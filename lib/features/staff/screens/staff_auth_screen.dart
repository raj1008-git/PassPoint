import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/staff_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/branch_repository.dart';

class StaffAuthScreen extends StatefulWidget {
  const StaffAuthScreen({super.key});

  @override
  State<StaffAuthScreen> createState() => _StaffAuthScreenState();
}

class _StaffAuthScreenState extends State<StaffAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.dark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Auth Card
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
                            children: [
                              // Icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.info,
                                  borderRadius: AppTheme.radiusMedium,
                                ),
                                child: const Icon(
                                  Icons.people_alt_outlined,
                                  color: AppTheme.white,
                                  size: 40,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Title
                              const Text('PMLIL Staff', style: AppTheme.h2),

                              const SizedBox(height: 8),

                              // Subtitle
                              const Text(
                                'Login or register your account',
                                style: AppTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Tab Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.greyLight.withOpacity(0.5),
                                  borderRadius: AppTheme.radiusSmall,
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: AppTheme.white,
                                  unselectedLabelColor: AppTheme.textSecondary,
                                  indicator: BoxDecoration(
                                    color: AppTheme.info,
                                    borderRadius: AppTheme.radiusSmall,
                                  ),
                                  dividerColor: Colors.transparent,
                                  tabs: const [
                                    Tab(text: 'Login'),
                                    Tab(text: 'Register'),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Tab Views
                              SizedBox(
                                height: 550,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [_LoginTab(), _RegisterTab()],
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
}

// Login Tab (UPDATED)
class _LoginTab extends StatefulWidget {
  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both phone number and password'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Use phone-based login
      await StaffAuthService.loginWithPhone(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      devLog('Staff logged in successfully');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/staff-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phone Field
          const Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Phone Number', style: AppTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '98XXXXXXXX',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.greyLight,
              border: OutlineInputBorder(
                borderRadius: AppTheme.radiusSmall,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Password Field
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Password', style: AppTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.greyLight,
              border: OutlineInputBorder(
                borderRadius: AppTheme.radiusSmall,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.grey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            onSubmitted: (_) => _signIn(),
          ),

          const SizedBox(height: 32),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.info,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusSmall,
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Register Tab (UPDATED)
class _RegisterTab extends StatefulWidget {
  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _selectedBranchId;
  String? _selectedBranchName;
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isKamaladiBranch =>
      _selectedBranchName?.toUpperCase() == 'KAMALADI';

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill required fields (Name, Phone, Branch, Password)',
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Check if Kamaladi and department not selected
    if (_isKamaladiBranch && _selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department for Kamaladi staff'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await StaffAuthService.register(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        password: _passwordController.text,
        branchId: _selectedBranchId!,
        branchName: _selectedBranchName!,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
      );

      devLog('Staff registration successful');

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.success, size: 28),
                SizedBox(width: 12),
                Text('Registration Submitted'),
              ],
            ),
            content: Text(
              'Your registration has been submitted successfully!\n\n'
              'Your account is pending approval from ${_isKamaladiBranch ? "the receptionist" : "HQ staff"}. '
              'You will be able to login once your account is approved.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: AppTheme.info),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          const Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Full Name', style: AppTheme.labelLarge),
              Text(' *', style: TextStyle(color: AppTheme.error)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.greyLight,
              border: OutlineInputBorder(
                borderRadius: AppTheme.radiusSmall,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Phone Field (MANDATORY)
          const Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Phone Number', style: AppTheme.labelLarge),
              Text(' *', style: TextStyle(color: AppTheme.error)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '98XXXXXXXX',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.greyLight,
              border: OutlineInputBorder(
                borderRadius: AppTheme.radiusSmall,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Email Field (OPTIONAL)
          const Row(
            children: [
              Icon(Icons.email_outlined, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Email (Optional)', style: AppTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'name@pmlil.com (optional)',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.greyLight,
              border: OutlineInputBorder(
                borderRadius: AppTheme.radiusSmall,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Password Field
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Password', style: AppTheme.labelLarge),
              Text(' *', style: TextStyle(color: AppTheme.error)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Min 6 characters',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.greyLight,
              border: OutlineInputBorder(
                borderRadius: AppTheme.radiusSmall,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.grey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Branch Dropdown
          _buildBranchDropdown(),

          const SizedBox(height: 16),

          // Department Dropdown (only for Kamaladi)
          if (_isKamaladiBranch) ...[
            _buildDepartmentDropdown(),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 24),

          // Register Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.info,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusSmall,
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppTheme.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phone number required. Email optional. Pending approval.',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return FutureBuilder(
      future: BranchRepository().getBranches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final branches = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_city, size: 18, color: AppTheme.info),
                SizedBox(width: 8),
                Text('Branch', style: AppTheme.labelLarge),
                Text(' *', style: TextStyle(color: AppTheme.error)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select branch',
                hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
                filled: true,
                fillColor: AppTheme.greyLight,
                border: OutlineInputBorder(
                  borderRadius: AppTheme.radiusSmall,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              value: _selectedBranchId,
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
                  setState(() {
                    _selectedBranchId = val;
                    _selectedBranchName = selected.name;
                    // Reset department if changing branch
                    _selectedDepartmentId = null;
                    _selectedDepartmentName = null;
                  });
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
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: const Text('Error loading departments'),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: AppTheme.radiusSmall,
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: const Text('No departments available'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.business_outlined, size: 18, color: AppTheme.info),
                SizedBox(width: 8),
                Text('Department', style: AppTheme.labelLarge),
                Text(' *', style: TextStyle(color: AppTheme.error)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select department',
                hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
                filled: true,
                fillColor: AppTheme.greyLight,
                border: OutlineInputBorder(
                  borderRadius: AppTheme.radiusSmall,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              value: _selectedDepartmentId,
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
                  setState(() {
                    _selectedDepartmentId = val;
                    _selectedDepartmentName = data['name'] ?? val;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
