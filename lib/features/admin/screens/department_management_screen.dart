import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/department_model.dart';
import '../../department/bloc/department_bloc.dart';
import '../../department/bloc/department_event.dart';
import '../../department/bloc/department_state.dart';

class DepartmentManagementScreen extends StatelessWidget {
  const DepartmentManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DepartmentBloc()..add(LoadDepartments()),
      child: const _DepartmentManagementView(),
    );
  }
}

class _DepartmentManagementView extends StatelessWidget {
  const _DepartmentManagementView();

  List<Department> _getDepartments(DepartmentState state) {
    if (state is DepartmentLoaded) return state.departments;
    if (state is DepartmentOperationInProgress) return state.departments;
    if (state is DepartmentOperationSuccess) return state.departments;
    if (state is DepartmentError) return state.departments;
    return [];
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
          'Department Management',
          style: TextStyle(color: AppTheme.dark),
        ),
      ),
      body: BlocConsumer<DepartmentBloc, DepartmentState>(
        listener: (context, state) {
          if (state is DepartmentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          if (state is DepartmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DepartmentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            );
          }

          final departments = _getDepartments(state);
          final isOperating = state is DepartmentOperationInProgress;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              return Column(
                children: [
                  // Stats Card
                  Container(
                    margin: EdgeInsets.all(isTablet ? 24 : 16),
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
                      ),
                      borderRadius: AppTheme.radiusLarge,
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isTablet ? 64 : 56,
                          height: isTablet ? 64 : 56,
                          decoration: BoxDecoration(
                            color: AppTheme.white.withOpacity(0.2),
                            borderRadius: AppTheme.radiusMedium,
                          ),
                          child: Icon(
                            Icons.business,
                            color: AppTheme.white,
                            size: isTablet ? 32 : 28,
                          ),
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Departments',
                                style: TextStyle(
                                  color: AppTheme.white.withOpacity(0.9),
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                departments.length.toString(),
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: isTablet ? 36 : 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isOperating)
                          ElevatedButton.icon(
                            onPressed: () => _showCreateDialog(context),
                            icon: const Icon(Icons.add, size: 20),
                            label: Text(
                              isTablet ? 'Add Department' : 'Add',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.white,
                              foregroundColor: AppTheme.primaryRed,
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 20 : 16,
                                vertical: isTablet ? 14 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.radiusSmall,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Department List
                  Expanded(
                    child: departments.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16,
                            ),
                            itemCount: departments.length,
                            itemBuilder: (context, index) {
                              final dept = departments[index];
                              return _buildDepartmentTile(
                                context,
                                dept,
                                isOperating,
                                isTablet,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: AppTheme.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text('No Departments Yet', style: AppTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Create your first department to get started',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentTile(
    BuildContext context,
    Department dept,
    bool isOperating,
    bool isTablet,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: AppTheme.greyLight, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 8,
        ),
        leading: Container(
          width: isTablet ? 48 : 44,
          height: isTablet ? 48 : 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: AppTheme.radiusSmall,
          ),
          child: Icon(
            Icons.business,
            color: AppTheme.primaryRed,
            size: isTablet ? 24 : 20,
          ),
        ),
        title: Text(
          dept.name,
          style: TextStyle(
            fontSize: isTablet ? 16 : 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Created: ${DateFormat('MMM dd, yyyy').format(dept.createdAt.toDate())}',
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        trailing: isOperating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditDialog(context, dept),
                    icon: const Icon(Icons.edit_outlined),
                    color: AppTheme.info,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(context, dept),
                    icon: const Icon(Icons.delete_outlined),
                    color: AppTheme.error,
                    tooltip: 'Delete',
                  ),
                ],
              ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Row(
          children: [
            Icon(Icons.add_business, color: AppTheme.primaryRed),
            SizedBox(width: 12),
            Text('Create Department'),
          ],
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Department Name',
            hintText: 'e.g., IT Department',
            prefixIcon: const Icon(Icons.business_outlined),
            border: OutlineInputBorder(borderRadius: AppTheme.radiusSmall),
          ),
          onSubmitted: (_) {
            if (nameController.text.trim().isNotEmpty) {
              context.read<DepartmentBloc>().add(
                CreateDepartment(nameController.text.trim()),
              );
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter department name'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }
              context.read<DepartmentBloc>().add(
                CreateDepartment(nameController.text.trim()),
              );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Department dept) {
    final nameController = TextEditingController(text: dept.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.info),
            SizedBox(width: 12),
            Text('Edit Department'),
          ],
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Department Name',
            prefixIcon: const Icon(Icons.business_outlined),
            border: OutlineInputBorder(borderRadius: AppTheme.radiusSmall),
          ),
          onSubmitted: (_) {
            if (nameController.text.trim().isNotEmpty &&
                nameController.text.trim() != dept.name) {
              context.read<DepartmentBloc>().add(
                UpdateDepartment(dept.id, nameController.text.trim()),
              );
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter department name'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }
              if (nameController.text.trim() == dept.name) {
                Navigator.of(dialogContext).pop();
                return;
              }
              context.read<DepartmentBloc>().add(
                UpdateDepartment(dept.id, nameController.text.trim()),
              );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Department dept) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            SizedBox(width: 12),
            Text('Delete Department'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${dept.name}"?\n\n'
          'This action cannot be undone. Staff members must be reassigned before deletion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DepartmentBloc>().add(DeleteDepartment(dept.id));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
