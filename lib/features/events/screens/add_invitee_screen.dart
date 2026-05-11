// lib/features/events/screens/add_invitee_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_gift_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../../data/repositories/event_gift_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/invite_repository.dart';
import '../bloc/gift_stock_bloc.dart';
import '../bloc/gift_stock_event.dart';
import '../bloc/gift_stock_state.dart';
import '../bloc/invite_bloc.dart';
import '../bloc/invite_event.dart';
import '../bloc/invite_state.dart';

class AddInviteeScreen extends StatelessWidget {
  const AddInviteeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final eventId = args['eventId'] as String;
    final event = args['event'] as EventModel;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => InviteBloc(
            repository: InviteRepository(
              eventRepository: EventRepository(),
              giftRepository: EventGiftRepository(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) =>
          GiftStockBloc(repository: EventGiftRepository())
            ..add(LoadGiftStock(eventId)),
        ),
      ],
      child: _AddInviteeView(eventId: eventId, event: event),
    );
  }
}

class _AddInviteeView extends StatefulWidget {
  final String eventId;
  final EventModel event;

  const _AddInviteeView({required this.eventId, required this.event});

  @override
  State<_AddInviteeView> createState() => _AddInviteeViewState();
}

class _AddInviteeViewState extends State<_AddInviteeView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isPmlilStaff = false;
  bool _isLookingUp = false;
  bool _lookupDone = false;
  String? _branchName;
  String? _departmentName;

  final List<EventGiftModel> _selectedGifts = [];
  final EmployeeRepository _employeeRepo = EmployeeRepository();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _lookupPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) return;

    setState(() {
      _isLookingUp = true;
      _lookupDone = false;
    });

    try {
      final employee = await _employeeRepo.getByPhone(phone);

      if (employee != null) {
        setState(() {
          _nameController.text = employee.fullName;
          _emailController.text = employee.email;
          _isPmlilStaff = true;
          _branchName = employee.branchName;
          _departmentName = employee.departmentName.isNotEmpty
              ? employee.departmentName
              : null;
          _lookupDone = true;
        });
        devLog(
          'AddInviteeScreen: employee found',
          params: {'name': employee.fullName},
        );
      } else {
        setState(() {
          _nameController.clear();
          _emailController.clear();
          _isPmlilStaff = false;
          _branchName = null;
          _departmentName = null;
          _lookupDone = true;
        });
        devLog('AddInviteeScreen: employee not found — manual entry');
      }
    } catch (e) {
      devLog(
        'AddInviteeScreen: lookup error',
        params: {'error': e.toString()},
      );
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  void _toggleGift(EventGiftModel gift) {
    setState(() {
      if (_selectedGifts.any((g) => g.id == gift.id)) {
        _selectedGifts.removeWhere((g) => g.id == gift.id);
      } else {
        _selectedGifts.add(gift);
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    context.read<InviteBloc>().add(
      CreateInvite(
        eventId: widget.eventId,
        eventName: widget.event.name,
        eventDate: widget.event.eventDate.toDate(),
        eventVenue: widget.event.venue,
        phone: _phoneController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        isPmlilStaff: _isPmlilStaff,
        branchName: _branchName,
        departmentName: _departmentName,
        selectedGifts: _selectedGifts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Add Invitee',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<InviteBloc, InviteState>(
        listener: (context, state) {
          if (state is InviteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Invitee added — QR email on its way'),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium),
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is InviteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium),
              ),
            );
          }
        },
        builder: (context, inviteState) {
          final isSubmitting = inviteState is InviteOperationInProgress;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 48 : 16,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Phone lookup ──────────────────────────────────
                      _buildSectionTitle('Contact', isTablet),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.search,
                              onFieldSubmitted: (_) => _lookupPhone(),
                              decoration: _inputDec(
                                label: 'Phone Number',
                                hint: '98XXXXXXXX',
                                icon: Icons.phone_outlined,
                                isTablet: isTablet,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Phone is required';
                                }
                                if (v.trim().length < 7) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: isTablet ? 58 : 52,
                            child: ElevatedButton(
                              onPressed:
                              _isLookingUp ? null : _lookupPhone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF7B1FA2),
                                foregroundColor: AppTheme.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.radiusMedium),
                                elevation: 0,
                              ),
                              child: _isLookingUp
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.white,
                                ),
                              )
                                  : const Icon(Icons.search_rounded),
                            ),
                          ),
                        ],
                      ),

                      // Auto-fill hint
                      if (_lookupDone)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                _isPmlilStaff
                                    ? Icons.check_circle_outline
                                    : Icons.info_outline,
                                size: 14,
                                color: _isPmlilStaff
                                    ? AppTheme.success
                                    : AppTheme.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isPmlilStaff
                                    ? 'PMLIL employee found — details auto-filled'
                                    : 'Not found in employee list — enter details manually',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isPmlilStaff
                                      ? AppTheme.success
                                      : AppTheme.warning,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: isTablet ? 20 : 16),

                      // ── Name ──────────────────────────────────────────
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDec(
                          label: 'Full Name',
                          hint: 'Invitee full name',
                          icon: Icons.person_outline_rounded,
                          isTablet: isTablet,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),

                      SizedBox(height: isTablet ? 20 : 16),

                      // ── Email ─────────────────────────────────────────
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDec(
                          label: 'Email',
                          hint: 'email@example.com',
                          icon: Icons.email_outlined,
                          isTablet: isTablet,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),

                      SizedBox(height: isTablet ? 20 : 16),

                      // ── PMLIL staff toggle ────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: AppTheme.radiusMedium,
                          border:
                          Border.all(color: AppTheme.greyLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.badge_outlined,
                                color: AppTheme.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'PMLIL Employee',
                                style: AppTheme.labelLarge,
                              ),
                            ),
                            Switch(
                              value: _isPmlilStaff,
                              onChanged: (val) =>
                                  setState(() => _isPmlilStaff = val),
                              activeColor: const Color(0xFF7B1FA2),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 28 : 24),

                      // ── Gift selection ────────────────────────────────
                      _buildSectionTitle(
                          'Assign Gifts (optional)', isTablet),
                      const SizedBox(height: 12),

                      BlocBuilder<GiftStockBloc, GiftStockState>(
                        builder: (context, giftState) {
                          if (giftState is GiftStockLoading ||
                              giftState is GiftStockInitial) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final gifts = switch (giftState) {
                            GiftStockLoaded s => s.gifts,
                            GiftStockOperationInProgress s => s.gifts,
                            GiftStockOperationSuccess s => s.gifts,
                            GiftStockError s => s.gifts,
                            _ => <EventGiftModel>[],
                          };

                          if (gifts.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: AppTheme.radiusMedium,
                                border: Border.all(
                                    color: AppTheme.greyLight),
                              ),
                              child: Text(
                                'No gifts in inventory. Add gifts first.',
                                style: AppTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return Column(
                            children: gifts.map((gift) {
                              final isSelected = _selectedGifts
                                  .any((g) => g.id == gift.id);
                              final isDisabled =
                                  gift.isOutOfStock && !isSelected;

                              return GestureDetector(
                                onTap: isDisabled
                                    ? null
                                    : () => _toggleGift(gift),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF7B1FA2)
                                        .withOpacity(0.08)
                                        : AppTheme.white,
                                    borderRadius: AppTheme.radiusMedium,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF7B1FA2)
                                          .withOpacity(0.4)
                                          : AppTheme.greyLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_box_rounded
                                            : Icons
                                            .check_box_outline_blank_rounded,
                                        color: isSelected
                                            ? const Color(0xFF7B1FA2)
                                            : isDisabled
                                            ? AppTheme.textTertiary
                                            : AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          gift.name,
                                          style: TextStyle(
                                            color: isDisabled
                                                ? AppTheme.textTertiary
                                                : AppTheme.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        gift.isOutOfStock
                                            ? 'Out of stock'
                                            : '${gift.remainingStock} left',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: gift.isOutOfStock
                                              ? AppTheme.error
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // ── Submit ────────────────────────────────────────
                      SizedBox(
                        height: isTablet ? 56 : 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B1FA2),
                            foregroundColor: AppTheme.white,
                            disabledBackgroundColor: AppTheme.greyLight,
                            shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.radiusMedium),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.white,
                            ),
                          )
                              : const Text(
                            'Add Invitee & Send QR',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: AppTheme.labelLarge.copyWith(
        fontSize: isTablet ? 15 : 13,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDec({
    required String label,
    required String hint,
    required IconData icon,
    required bool isTablet,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.white,
      labelStyle: AppTheme.bodyMedium,
      hintStyle:
      AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
      contentPadding: EdgeInsets.symmetric(
          horizontal: 16, vertical: isTablet ? 18 : 14),
      border: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: BorderSide(color: AppTheme.greyLight)),
      enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: BorderSide(color: AppTheme.greyLight)),
      focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide:
          const BorderSide(color: Color(0xFF7B1FA2), width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: const BorderSide(color: AppTheme.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide:
          const BorderSide(color: AppTheme.error, width: 2)),
    );
  }
}