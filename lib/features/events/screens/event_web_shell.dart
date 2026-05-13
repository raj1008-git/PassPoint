// lib/features/events/screens/event_web_shell.dart
//
// Flutter Web entry point for the event management feature.
// Wraps existing screens in a responsive sidebar + content layout.
//
// On WIDE (≥ 900px): persistent left sidebar + content area
// On NARROW (< 900px): bottom nav bar (same screens, no sidebar)
//
// All data logic lives in the existing Blocs/Repositories.
// This file is layout/navigation only.
//
// Routes that use this shell:
//   '/event-web'  → EventWebShell (replaces /event-dashboard on web)
//
// The scanner screen is intentionally excluded from web nav —
// QR scanning requires a physical camera on mobile.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/services/event_manager_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_gift_model.dart';
import '../../../data/models/event_invite_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../../data/repositories/event_gift_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/invite_repository.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../bloc/gift_stock_bloc.dart';
import '../bloc/gift_stock_event.dart';
import '../bloc/gift_stock_state.dart';
import '../bloc/invite_bloc.dart';
import '../bloc/invite_event.dart';
import '../bloc/invite_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shell entry point
// ─────────────────────────────────────────────────────────────────────────────

class EventWebShell extends StatelessWidget {
  const EventWebShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => EventBloc(repository: EventRepository())
            ..add(LoadAllEvents()),
        ),
        BlocProvider(
          create: (_) => InviteBloc(
            repository: InviteRepository(
              eventRepository: EventRepository(),
              giftRepository: EventGiftRepository(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => GiftStockBloc(repository: EventGiftRepository()),
        ),
      ],
      child: const _WebShellView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav destinations
// ─────────────────────────────────────────────────────────────────────────────

enum _WebTab { dashboard, createEvent, gifts, invitees, export }

extension _WebTabExt on _WebTab {
  String get label {
    switch (this) {
      case _WebTab.dashboard:
        return 'Dashboard';
      case _WebTab.createEvent:
        return 'New Event';
      case _WebTab.gifts:
        return 'Gift Inventory';
      case _WebTab.invitees:
        return 'Invitees';
      case _WebTab.export:
        return 'Export';
    }
  }

  IconData get icon {
    switch (this) {
      case _WebTab.dashboard:
        return Icons.dashboard_outlined;
      case _WebTab.createEvent:
        return Icons.add_circle_outline_rounded;
      case _WebTab.gifts:
        return Icons.card_giftcard_outlined;
      case _WebTab.invitees:
        return Icons.people_outline_rounded;
      case _WebTab.export:
        return Icons.download_outlined;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case _WebTab.dashboard:
        return Icons.dashboard_rounded;
      case _WebTab.createEvent:
        return Icons.add_circle_rounded;
      case _WebTab.gifts:
        return Icons.card_giftcard_rounded;
      case _WebTab.invitees:
        return Icons.people_rounded;
      case _WebTab.export:
        return Icons.download_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shell view
// ─────────────────────────────────────────────────────────────────────────────

class _WebShellView extends StatefulWidget {
  const _WebShellView();

  @override
  State<_WebShellView> createState() => _WebShellViewState();
}

class _WebShellViewState extends State<_WebShellView> {
  _WebTab _activeTab = _WebTab.dashboard;

  // Selected event — needed for gifts / invitees / export tabs
  EventModel? _selectedEvent;

  static const Color _purple = Color(0xFF7B1FA2);
  static const Color _purpleLight = Color(0xFFAB47BC);

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
            const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await EventManagerAuthService.signOut();
      devLog('EventWebShell: signed out');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/role-selection');
      }
    }
  }

  void _selectTab(_WebTab tab) => setState(() => _activeTab = tab);

  void _selectEvent(EventModel event) {
    setState(() {
      _selectedEvent = event;
      _activeTab = _WebTab.invitees;
    });
    // Load invites + gifts for selected event
    context.read<InviteBloc>().add(LoadInvites(event.id));
    context.read<GiftStockBloc>().add(LoadGiftStock(event.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          if (isWide) {
            return _buildWideLayout(constraints);
          } else {
            return _buildNarrowLayout(constraints);
          }
        },
      ),
    );
  }

  // ── Wide layout: sidebar + content ───────────────────────────────────────

  Widget _buildWideLayout(BoxConstraints constraints) {
    return Row(
      children: [
        // Sidebar
        _buildSidebar(constraints),

        // Divider
        Container(width: 1, color: AppTheme.greyLight),

        // Content
        Expanded(child: _buildContent(wide: true)),
      ],
    );
  }

  Widget _buildSidebar(BoxConstraints constraints) {
    final isCollapsed = constraints.maxWidth < 1100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 240,
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo strip
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_purple, _purpleLight],
              ),
            ),
            child: isCollapsed
                ? const Center(
              child: Icon(Icons.event_rounded,
                  color: AppTheme.white, size: 28),
            )
                : Row(
              children: [
                const Icon(Icons.event_rounded,
                    color: AppTheme.white, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Event Manager',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Nav items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 8 : 12,
                vertical: 4,
              ),
              children: _WebTab.values.map((tab) {
                final isActive = _activeTab == tab;
                return Tooltip(
                  message: isCollapsed ? tab.label : '',
                  preferBelow: false,
                  child: GestureDetector(
                    onTap: () => _selectTab(tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: EdgeInsets.symmetric(
                        horizontal: isCollapsed ? 0 : 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _purple.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: AppTheme.radiusMedium,
                      ),
                      child: isCollapsed
                          ? Center(
                        child: Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          color: isActive
                              ? _purple
                              : AppTheme.textSecondary,
                          size: 22,
                        ),
                      )
                          : Row(
                        children: [
                          Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            color: isActive
                                ? _purple
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: isActive
                                  ? _purple
                                  : AppTheme.textSecondary,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sign out
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8 : 12,
              vertical: 16,
            ),
            child: GestureDetector(
              onTap: _handleSignOut,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 0 : 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.06),
                  borderRadius: AppTheme.radiusMedium,
                ),
                child: isCollapsed
                    ? Center(
                  child: Icon(Icons.logout_rounded,
                      color: AppTheme.error, size: 20),
                )
                    : Row(
                  children: const [
                    Icon(Icons.logout_rounded,
                        color: AppTheme.error, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Narrow layout: top app bar + bottom nav ───────────────────────────────

  Widget _buildNarrowLayout(BoxConstraints constraints) {
    return Column(
      children: [
        // App bar
        Container(
          height: 56 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_purple, _purpleLight],
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.event_rounded,
                  color: AppTheme.white, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Event Manager',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppTheme.white),
                onPressed: _handleSignOut,
              ),
            ],
          ),
        ),

        // Content
        Expanded(child: _buildContent(wide: false)),

        // Bottom nav
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.greyLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: _WebTab.values.map((tab) {
            final isActive = _activeTab == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => _selectTab(tab),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        color: isActive ? _purple : AppTheme.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: isActive ? _purple : AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Content router ────────────────────────────────────────────────────────

  Widget _buildContent({required bool wide}) {
    switch (_activeTab) {
      case _WebTab.dashboard:
        return _WebDashboardTab(
          onEventSelected: _selectEvent,
          wide: wide,
        );
      case _WebTab.createEvent:
        return _WebCreateEventTab(
          onCreated: () => _selectTab(_WebTab.dashboard),
          wide: wide,
        );
      case _WebTab.gifts:
        return _selectedEvent == null
            ? _buildSelectEventPrompt(
          'Select an event from Dashboard first',
          Icons.card_giftcard_outlined,
        )
            : _WebGiftsTab(event: _selectedEvent!, wide: wide);
      case _WebTab.invitees:
        return _selectedEvent == null
            ? _buildSelectEventPrompt(
          'Select an event from Dashboard first',
          Icons.people_outline_rounded,
        )
            : _WebInviteesTab(event: _selectedEvent!, wide: wide);
      case _WebTab.export:
        return _selectedEvent == null
            ? _buildSelectEventPrompt(
          'Select an event from Dashboard to export',
          Icons.download_outlined,
        )
            : _WebExportTab(event: _selectedEvent!, wide: wide);
    }
  }

  Widget _buildSelectEventPrompt(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(message, style: AppTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _selectTab(_WebTab.dashboard),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium),
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab: Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _WebDashboardTab extends StatelessWidget {
  final ValueChanged<EventModel> onEventSelected;
  final bool wide;

  const _WebDashboardTab({
    required this.onEventSelected,
    required this.wide,
  });

  static const Color _purple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoading || state is EventInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = switch (state) {
          EventLoaded s => s.events,
          EventOperationInProgress s => s.events,
          EventOperationSuccess s => s.events,
          EventError s => s.events,
          _ => <EventModel>[],
        };

        final draft = events.where((e) => e.isDraft).length;
        final active = events.where((e) => e.isActive).length;
        final completed = events.where((e) => e.isCompleted).length;



        // Added the new functionality
        return CustomScrollView(
          slivers: [
            // Page header
            SliverToBoxAdapter(
              child: _WebPageHeader(
                title: 'Events Dashboard',
                subtitle: '${events.length} total events',
              ),
            ),

            // Summary row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    _buildSummaryChip('Draft', draft, AppTheme.warning),
                    const SizedBox(width: 12),
                    _buildSummaryChip('Active', active, AppTheme.success),
                    const SizedBox(width: 12),
                    _buildSummaryChip(
                        'Completed', completed, AppTheme.info),
                  ],
                ),
              ),
            ),

            // Event grid / list
            events.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Text(
                  'No events yet — create one to get started',
                  style: AppTheme.bodyMedium,
                ),
              ),
            )
                : SliverPadding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24),
              sliver: wide
                  ? SliverGrid(
                gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.9,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildEventCard(
                      context, events[i]),
                  childCount: events.length,
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                    padding:
                    const EdgeInsets.only(bottom: 12),
                    child: _buildEventCard(
                        context, events[i]),
                  ),
                  childCount: events.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final statusColor = switch (event.status) {
      'draft' => AppTheme.warning,
      'active' => AppTheme.success,
      'completed' => AppTheme.info,
      _ => AppTheme.grey,
    };

    return GestureDetector(
      onTap: () => onEventSelected(event),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppTheme.greyLight.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: AppTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  child: Text(
                    event.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.venue,
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy')
                      .format(event.eventDate.toDate()),
                  style: AppTheme.bodySmall,
                ),
                const Spacer(),
                const Icon(Icons.people_outline,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 3),
                Text('${event.totalInvited}',
                    style: AppTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab: Create Event
// ─────────────────────────────────────────────────────────────────────────────

class _WebCreateEventTab extends StatefulWidget {
  final VoidCallback onCreated;
  final bool wide;

  const _WebCreateEventTab({
    required this.onCreated,
    required this.wide,
  });

  @override
  State<_WebCreateEventTab> createState() => _WebCreateEventTabState();
}

class _WebCreateEventTabState extends State<_WebCreateEventTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _date;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _venueCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF7B1FA2)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) {
      if (_date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select an event date'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusMedium),
          ),
        );
      }
      return;
    }
    final uid = await EventManagerAuthService.getUid();
    if (uid == null || !mounted) return;

    context.read<EventBloc>().add(
      CreateEvent(
        name: _nameCtrl.text.trim(),
        venue: _venueCtrl.text.trim(),
        eventDate: _date!,
        description: _descCtrl.text.trim(),
        createdByUid: uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventOperationSuccess) {
          _nameCtrl.clear();
          _venueCtrl.clear();
          _descCtrl.clear();
          setState(() => _date = null);
          widget.onCreated();
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
      child: SingleChildScrollView(
        padding: EdgeInsets.all(widget.wide ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _WebPageHeader(
                  title: 'Create New Event',
                  subtitle: 'Fill in the details below',
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _WebField(
                        controller: _nameCtrl,
                        label: 'Event Name',
                        hint: 'e.g. Annual Staff Gathering 2025',
                        icon: Icons.celebration_outlined,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _WebField(
                        controller: _venueCtrl,
                        label: 'Venue',
                        hint: 'e.g. Hotel Annapurna, Kathmandu',
                        icon: Icons.location_on_outlined,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Date picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: AppTheme.radiusMedium,
                            border:
                            Border.all(color: AppTheme.greyLight),
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
                                  _date == null
                                      ? 'Select Event Date'
                                      : DateFormat('EEEE, dd MMMM yyyy')
                                      .format(_date!),
                                  style: _date == null
                                      ? AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textTertiary)
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Event details, agenda, notes...',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: AppTheme.white,
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
                                color: Color(0xFF7B1FA2), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      BlocBuilder<EventBloc, EventState>(
                        builder: (context, state) {
                          final loading =
                          state is EventOperationInProgress;
                          return SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF7B1FA2),
                                foregroundColor: AppTheme.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.radiusMedium),
                                elevation: 0,
                              ),
                              child: loading
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab: Gift Inventory
// ─────────────────────────────────────────────────────────────────────────────

class _WebGiftsTab extends StatefulWidget {
  final EventModel event;
  final bool wide;

  const _WebGiftsTab({required this.event, required this.wide});

  @override
  State<_WebGiftsTab> createState() => _WebGiftsTabState();
}

class _WebGiftsTabState extends State<_WebGiftsTab> {
  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GiftStockBloc, GiftStockState>(
      listener: (context, state) {
        if (state is GiftStockOperationSuccess) {
          _nameCtrl.clear();
          _stockCtrl.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium),
            ),
          );
        }
        if (state is GiftStockError) {
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
        final gifts = switch (state) {
          GiftStockLoaded s => s.gifts,
          GiftStockOperationInProgress s => s.gifts,
          GiftStockOperationSuccess s => s.gifts,
          GiftStockError s => s.gifts,
          _ => <EventGiftModel>[],
        };

        return SingleChildScrollView(
          padding: EdgeInsets.all(widget.wide ? 32 : 16),
          child: widget.wide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: gift list
              Expanded(flex: 3, child: _buildGiftList(gifts)),
              const SizedBox(width: 24),
              // Right: add form
              Expanded(flex: 2, child: _buildAddForm(context)),
            ],
          )
              : Column(
            children: [
              _buildAddForm(context),
              const SizedBox(height: 24),
              _buildGiftList(gifts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGiftList(List<EventGiftModel> gifts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WebPageHeader(
          title: 'Gift Inventory',
          subtitle: '${gifts.length} gift type(s) · ${widget.event.name}',
        ),
        if (gifts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No gifts added yet',
                style:
                AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
              ),
            ),
          )
        else
          ...gifts.map((g) {
            final fraction = g.stockFraction;
            final color = fraction > 0.5
                ? AppTheme.success
                : fraction > 0.2
                ? AppTheme.warning
                : AppTheme.error;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: AppTheme.radiusLarge,
                boxShadow: AppTheme.cardShadow,
                border: Border.all(
                    color: AppTheme.greyLight.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(g.name,
                            style: AppTheme.labelLarge),
                      ),
                      Text(
                        '${g.remainingStock} / ${g.totalStock}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (g.assignedCount == 0) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => context
                              .read<GiftStockBloc>()
                              .add(DeleteGift(g.id)),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppTheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: AppTheme.radiusSmall,
                    child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: AppTheme.greyLight,
                      color: color,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAddForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.greyLight.withOpacity(0.5)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Gift Type', style: AppTheme.h3.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            _WebField(
              controller: _nameCtrl,
              label: 'Gift Name',
              hint: 'e.g. Pen, Cap, T-Shirt',
              icon: Icons.card_giftcard_outlined,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _WebField(
              controller: _stockCtrl,
              label: 'Total Stock',
              hint: 'e.g. 500',
              icon: Icons.inventory_2_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Enter valid quantity';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                context.read<GiftStockBloc>().add(
                  AddGift(
                    eventId: widget.event.id,
                    name: _nameCtrl.text.trim(),
                    totalStock:
                    int.parse(_stockCtrl.text.trim()),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Gift'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab: Invitees
// ─────────────────────────────────────────────────────────────────────────────

class _WebInviteesTab extends StatefulWidget {
  final EventModel event;
  final bool wide;

  const _WebInviteesTab({required this.event, required this.wide});

  @override
  State<_WebInviteesTab> createState() => _WebInviteesTabState();
}

class _WebInviteesTabState extends State<_WebInviteesTab> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _employeeRepo = EmployeeRepository();

  bool _isLookingUp = false;
  bool _isPmlilStaff = false;
  String? _branchName;
  String? _departmentName;
  final List<String> _selectedGiftIds = [];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupPhone() async {
    setState(() => _isLookingUp = true);
    try {
      final emp =
      await _employeeRepo.getByPhone(_phoneCtrl.text.trim());
      if (emp != null && mounted) {
        setState(() {
          _nameCtrl.text = emp.fullName;
          _emailCtrl.text = emp.email;
          _isPmlilStaff = true;
          _branchName = emp.branchName;
          _departmentName =
          emp.departmentName.isNotEmpty ? emp.departmentName : null;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InviteBloc, InviteState>(
      listener: (context, state) {
        if (state is InviteOperationSuccess) {
          _phoneCtrl.clear();
          _nameCtrl.clear();
          _emailCtrl.clear();
          setState(() {
            _isPmlilStaff = false;
            _branchName = null;
            _departmentName = null;
            _selectedGiftIds.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invitee added — QR email on its way'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium),
            ),
          );
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
        final invites = switch (inviteState) {
          InviteLoaded s => s.invites,
          InviteOperationInProgress s => s.invites,
          InviteOperationSuccess s => s.invites,
          InviteError s => s.invites,
          _ => <EventInviteModel>[],
        };

        return SingleChildScrollView(
          padding: EdgeInsets.all(widget.wide ? 32 : 16),
          child: widget.wide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildInviteeList(invites)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildAddForm(context)),
            ],
          )
              : Column(
            children: [
              _buildAddForm(context),
              const SizedBox(height: 24),
              _buildInviteeList(invites),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInviteeList(List<EventInviteModel> invites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WebPageHeader(
          title: 'Invitees',
          subtitle: '${invites.length} invited · ${widget.event.name}',
        ),
        if (invites.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No invitees yet',
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.textTertiary),
              ),
            ),
          )
        else
          ...invites.map((inv) {
            final statusColor = switch (inv.attendanceStatus) {
              'checked_in' => AppTheme.checkedInGreenIcon,
              'checked_out' => AppTheme.checkedOutBlueIcon,
              _ => AppTheme.pendingOrangeIcon,
            };
            final statusLabel = switch (inv.attendanceStatus) {
              'checked_in' => 'Checked In',
              'checked_out' => 'Checked Out',
              _ => 'Pending',
            };

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: AppTheme.radiusMedium,
                boxShadow: AppTheme.cardShadow,
                border: Border.all(
                    color: AppTheme.greyLight.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                    const Color(0xFF7B1FA2).withOpacity(0.12),
                    child: Text(
                      inv.name.isNotEmpty
                          ? inv.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF7B1FA2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inv.name, style: AppTheme.labelLarge),
                        Text(
                          inv.isPmlilStaff &&
                              inv.branchName != null
                              ? inv.branchName!
                              : inv.phone,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    inv.qrEmailSent
                        ? Icons.mark_email_read_outlined
                        : Icons.email_outlined,
                    size: 16,
                    color: inv.qrEmailSent
                        ? AppTheme.success
                        : AppTheme.textTertiary,
                  ),
                  if (inv.isPending) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context
                          .read<InviteBloc>()
                          .add(DeleteInvite(inv.id)),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAddForm(BuildContext context) {
    return BlocBuilder<GiftStockBloc, GiftStockState>(
      builder: (context, giftState) {
        final gifts = switch (giftState) {
          GiftStockLoaded s => s.gifts,
          GiftStockOperationInProgress s => s.gifts,
          GiftStockOperationSuccess s => s.gifts,
          GiftStockError s => s.gifts,
          _ => <EventGiftModel>[],
        };

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: AppTheme.radiusLarge,
            boxShadow: AppTheme.cardShadow,
            border:
            Border.all(color: AppTheme.greyLight.withOpacity(0.5)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Invitee',
                    style: AppTheme.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 16),

                // Phone + lookup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _WebField(
                        controller: _phoneCtrl,
                        label: 'Phone',
                        hint: '98XXXXXXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().length < 7
                            ? 'Enter valid phone'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLookingUp ? null : _lookupPhone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B1FA2),
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
                              color: AppTheme.white),
                        )
                            : const Icon(Icons.search_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WebField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  hint: 'Invitee full name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 12),
                _WebField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'email@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // PMLIL toggle
                Row(
                  children: [
                    const Text('PMLIL Employee',
                        style: AppTheme.labelLarge),
                    const Spacer(),
                    Switch(
                      value: _isPmlilStaff,
                      onChanged: (v) =>
                          setState(() => _isPmlilStaff = v),
                      activeColor: const Color(0xFF7B1FA2),
                    ),
                  ],
                ),

                if (gifts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Assign Gifts',
                      style: AppTheme.labelMedium),
                  const SizedBox(height: 8),
                  ...gifts.map((g) {
                    final sel = _selectedGiftIds.contains(g.id);
                    return GestureDetector(
                      onTap: g.isOutOfStock && !sel
                          ? null
                          : () => setState(() {
                        if (sel) {
                          _selectedGiftIds.remove(g.id);
                        } else {
                          _selectedGiftIds.add(g.id);
                        }
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFF7B1FA2).withOpacity(0.08)
                              : AppTheme.background,
                          borderRadius: AppTheme.radiusMedium,
                          border: Border.all(
                            color: sel
                                ? const Color(0xFF7B1FA2).withOpacity(0.4)
                                : AppTheme.greyLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              sel
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              color: sel
                                  ? const Color(0xFF7B1FA2)
                                  : AppTheme.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(g.name,
                                  style: AppTheme.bodyMedium),
                            ),
                            Text(
                              g.isOutOfStock
                                  ? 'Out of stock'
                                  : '${g.remainingStock} left',
                              style: TextStyle(
                                fontSize: 11,
                                color: g.isOutOfStock
                                    ? AppTheme.error
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 16),
                BlocBuilder<InviteBloc, InviteState>(
                  builder: (context, state) {
                    final loading = state is InviteOperationInProgress;
                    return ElevatedButton.icon(
                      onPressed: loading
                          ? null
                          : () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        final selectedGiftModels = gifts
                            .where((g) =>
                            _selectedGiftIds.contains(g.id))
                            .toList();
                        context.read<InviteBloc>().add(
                          CreateInvite(
                            eventId: widget.event.id,
                            eventName: widget.event.name,
                            eventDate: widget.event.eventDate
                                .toDate(),
                            eventVenue: widget.event.venue,
                            phone: _phoneCtrl.text.trim(),
                            name: _nameCtrl.text.trim(),
                            email: _emailCtrl.text.trim(),
                            isPmlilStaff: _isPmlilStaff,
                            branchName: _branchName,
                            departmentName: _departmentName,
                            selectedGifts: selectedGiftModels,
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Add & Send QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B1FA2),
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusMedium),
                        elevation: 0,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab: Export
// ─────────────────────────────────────────────────────────────────────────────

class _WebExportTab extends StatelessWidget {
  final EventModel event;
  final bool wide;

  const _WebExportTab({required this.event, required this.wide});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InviteBloc, InviteState>(
      builder: (context, state) {
        final invites = switch (state) {
          InviteLoaded s => s.invites,
          InviteOperationInProgress s => s.invites,
          InviteOperationSuccess s => s.invites,
          InviteError s => s.invites,
          _ => <EventInviteModel>[],
        };

        final checkedIn = invites.where((i) => !i.isPending).length;
        final checkedOut = invites.where((i) => i.isCheckedOut).length;
        final gifts = invites.fold<int>(
            0, (sum, i) => sum + i.receivedGiftCount);

        return SingleChildScrollView(
          padding: EdgeInsets.all(wide ? 32 : 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WebPageHeader(
                  title: 'Export',
                  subtitle: event.name,
                ),

                // Summary grid
                GridView.count(
                  crossAxisCount: wide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.8,
                  children: [
                    _exportStat('Invited', invites.length,
                        AppTheme.totalPurpleIcon),
                    _exportStat(
                        'Attended', checkedIn, AppTheme.success),
                    _exportStat(
                        'Checked Out', checkedOut, AppTheme.info),
                    _exportStat('Gifts', gifts, AppTheme.warning),
                  ],
                ),

                const SizedBox(height: 24),

                Text('Export Options',
                    style:
                    AppTheme.h3.copyWith(fontSize: 17)),
                const SizedBox(height: 12),

                // Note: web CSV export requires a different
                // download mechanism than mobile (no share sheet).
                // The buttons below navigate to the mobile export
                // screen which handles both platforms via share_plus.
                _exportCard(
                  context,
                  title: 'Attendance Report',
                  subtitle:
                  'Name, phone, branch, check-in/out times',
                  icon: Icons.people_outline_rounded,
                  onTap: () => Navigator.of(context).pushNamed(
                    '/event-export',
                    arguments: {'eventId': event.id},
                  ),
                ),
                const SizedBox(height: 10),
                _exportCard(
                  context,
                  title: 'Gift Distribution Report',
                  subtitle:
                  'Per-gift received / declined breakdown',
                  icon: Icons.card_giftcard_outlined,
                  onTap: () => Navigator.of(context).pushNamed(
                    '/event-export',
                    arguments: {'eventId': event.id},
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.08),
                    borderRadius: AppTheme.radiusMedium,
                    border: Border.all(
                        color: AppTheme.info.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline,
                          size: 16, color: AppTheme.info),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tapping an export option opens the full export screen '
                              'which downloads a CSV file.',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _exportStat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _exportCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: AppTheme.cardShadow,
          border:
          Border.all(color: AppTheme.greyLight.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7B1FA2).withOpacity(0.1),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Icon(icon,
                  color: const Color(0xFF7B1FA2), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.download_rounded,
                color: Color(0xFF7B1FA2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _WebPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _WebPageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTheme.h2.copyWith(fontSize: 22)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTheme.bodyMedium),
          const SizedBox(height: 12),
          Divider(color: AppTheme.greyLight, height: 1),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _WebField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _WebField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        filled: true,
        fillColor: AppTheme.white,
        labelStyle: AppTheme.bodyMedium,
        hintStyle: AppTheme.bodyMedium
            .copyWith(color: AppTheme.textTertiary),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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