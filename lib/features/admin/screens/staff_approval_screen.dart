import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../staff/bloc/staff_approoval_state.dart';
import '../../staff/bloc/staff_approval_bloc.dart';
import '../../staff/bloc/staff_approval_event.dart';

class StaffApprovalScreen extends StatelessWidget {
  const StaffApprovalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffApprovalBloc()..add(LoadPendingStaff()),
      child: const _StaffApprovalView(),
    );
  }
}

class _StaffApprovalView extends StatelessWidget {
  const _StaffApprovalView();

  List<UserModel> _getPendingStaff(StaffApprovalState state) {
    if (state is StaffApprovalLoaded) return state.pendingStaff;
    if (state is StaffApprovalOperationInProgress) return state.pendingStaff;
    if (state is StaffApprovalOperationSuccess) return state.pendingStaff;
    if (state is StaffApprovalError) return state.pendingStaff;
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
          'Staff Registration Requests',
          style: TextStyle(color: AppTheme.dark),
        ),
      ),
      body: BlocConsumer<StaffApprovalBloc, StaffApprovalState>(
        listener: (context, state) {
          if (state is StaffApprovalOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          if (state is StaffApprovalError) {
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
          if (state is StaffApprovalLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.info),
            );
          }

          final pendingStaff = _getPendingStaff(state);
          final isOperating = state is StaffApprovalOperationInProgress;

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
                        colors: [AppTheme.info, AppTheme.info.withOpacity(0.8)],
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
                            Icons.pending_actions,
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
                                'Pending Approvals',
                                style: TextStyle(
                                  color: AppTheme.white.withOpacity(0.9),
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pendingStaff.length.toString(),
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: isTablet ? 36 : 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (pendingStaff.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: isTablet ? 18 : 16,
                                  color: AppTheme.info,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Action Required',
                                  style: TextStyle(
                                    color: AppTheme.info,
                                    fontSize: isTablet ? 13 : 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Staff List
                  Expanded(
                    child: pendingStaff.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16,
                            ),
                            itemCount: pendingStaff.length,
                            itemBuilder: (context, index) {
                              final staff = pendingStaff[index];
                              return _buildStaffTile(
                                context,
                                staff,
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
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.success.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text('All Caught Up!', style: AppTheme.h3),
          const SizedBox(height: 8),
          Text(
            'No pending staff registrations at the moment',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTile(
    BuildContext context,
    UserModel staff,
    bool isOperating,
    bool isTablet,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.warning.withOpacity(0.3), width: 2),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        children: [
          // Header with status badge
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 56 : 48,
                  height: isTablet ? 56 : 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.info, AppTheme.info.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.white,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pending,
                              size: isTablet ? 14 : 12,
                              color: AppTheme.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PENDING APPROVAL',
                              style: TextStyle(
                                fontSize: isTablet ? 11 : 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.warning,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.email_outlined,
                  'Email',
                  staff.email ?? 'Not provided',
                  isTablet,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Phone',
                  staff.phoneNumber,
                  isTablet,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.business_outlined,
                  'Department',
                  staff.departmentName ?? 'N/A',
                  isTablet,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time,
                  'Registered',
                  DateFormat(
                    'MMM dd, yyyy - hh:mm a',
                  ).format(staff.createdAt.toDate()),
                  isTablet,
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: isOperating
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showRejectConfirmation(context, staff),
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            foregroundColor: AppTheme.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 14 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusSmall,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showApproveConfirmation(context, staff),
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            foregroundColor: AppTheme.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 14 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isTablet,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isTablet ? 20 : 18, color: AppTheme.info),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showApproveConfirmation(BuildContext context, UserModel staff) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success),
            SizedBox(width: 12),
            Text('Approve Staff'),
          ],
        ),
        content: Text(
          'Approve ${staff.name} as a staff member?\n\n'
          'They will be able to:\n'
          '• Login to the Staff Dashboard\n'
          '• View visitor requests\n'
          '• Appear in "Person to Meet" dropdown',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StaffApprovalBloc>().add(ApproveStaff(staff.uid));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(BuildContext context, UserModel staff) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            SizedBox(width: 12),
            Text('Reject Staff'),
          ],
        ),
        content: Text(
          'Reject ${staff.name}\'s registration?\n\n'
          'This will:\n'
          '• Remove their account from the system\n'
          '• Prevent them from logging in\n'
          '• This action cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StaffApprovalBloc>().add(RejectStaff(staff.uid));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
