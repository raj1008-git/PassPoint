// lib/features/events/screens/event_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/services/event_manager_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/event_repository.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class EventCreateScreen extends StatelessWidget {
  const EventCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventBloc(repository: EventRepository()),
      child: const _EventCreateView(),
    );
  }
}

class _EventCreateView extends StatefulWidget {
  const _EventCreateView();

  @override
  State<_EventCreateView> createState() => _EventCreateViewState();
}

class _EventCreateViewState extends State<_EventCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF7B1FA2),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an event date'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
        ),
      );
      return;
    }

    final uid = await EventManagerAuthService.getUid();
    if (uid == null) return;

    if (mounted) {
      context.read<EventBloc>().add(
        CreateEvent(
          name: _nameController.text.trim(),
          venue: _venueController.text.trim(),
          eventDate: _selectedDate!,
          description: _descriptionController.text.trim(),
          createdByUid: uid,
        ),
      );
    }
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
          'New Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventOperationSuccess) {
            devLog('EventCreateScreen: event created');
            Navigator.of(context).pop();
          }
          if (state is EventError) {
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
        builder: (context, state) {
          final isLoading = state is EventOperationInProgress;

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
                      _buildField(
                        controller: _nameController,
                        label: 'Event Name',
                        hint: 'e.g. Annual Staff Gathering 2025',
                        icon: Icons.celebration_outlined,
                        isTablet: isTablet,
                        validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Event name is required'
                            : null,
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      _buildField(
                        controller: _venueController,
                        label: 'Venue',
                        hint: 'e.g. Hotel Annapurna, Kathmandu',
                        icon: Icons.location_on_outlined,
                        isTablet: isTablet,
                        validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Venue is required'
                            : null,
                      ),
                      SizedBox(height: isTablet ? 20 : 16),

                      // Date picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isTablet ? 18 : 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: AppTheme.radiusMedium,
                            border: Border.all(color: AppTheme.greyLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? 'Select Event Date'
                                      : DateFormat('EEEE, dd MMMM yyyy')
                                      .format(_selectedDate!),
                                  style: _selectedDate == null
                                      ? AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textTertiary,
                                  )
                                      : AppTheme.bodyLarge,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 20 : 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Event details, agenda, notes...',
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 60),
                            child: Icon(
                              Icons.notes_rounded,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          filled: true,
                          fillColor: AppTheme.white,
                          labelStyle: AppTheme.bodyMedium,
                          hintStyle: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.textTertiary),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.radiusMedium,
                            borderSide:
                            BorderSide(color: AppTheme.greyLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppTheme.radiusMedium,
                            borderSide:
                            BorderSide(color: AppTheme.greyLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppTheme.radiusMedium,
                            borderSide: const BorderSide(
                              color: Color(0xFF7B1FA2),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        height: isTablet ? 56 : 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B1FA2),
                            foregroundColor: AppTheme.white,
                            disabledBackgroundColor: AppTheme.greyLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusMedium,
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.white,
                            ),
                          )
                              : const Text(
                            'Create Event',
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isTablet,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.white,
        labelStyle: AppTheme.bodyMedium,
        hintStyle:
        AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 18 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: BorderSide(color: AppTheme.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: BorderSide(color: AppTheme.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide:
          const BorderSide(color: Color(0xFF7B1FA2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppTheme.radiusMedium,
          borderSide:
          const BorderSide(color: AppTheme.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}