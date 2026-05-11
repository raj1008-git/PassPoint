// lib/features/events/screens/event_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/services/event_manager_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/event_repository.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class EventDashboardScreen extends StatelessWidget {
  const EventDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventBloc(repository: EventRepository())
        ..add(LoadAllEvents()),
      child: const _EventDashboardView(),
    );
  }
}

class _EventDashboardView extends StatelessWidget {
  const _EventDashboardView();

  Future<void> _handleSignOut(BuildContext context) async {
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
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await EventManagerAuthService.signOut();
      devLog('EventDashboard: signed out');
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/role-selection');
      }
    }
  }

  void _navigateToCreate(BuildContext context, EventBloc bloc) {
    Navigator.of(context)
        .pushNamed('/event-create')
        .then((_) => bloc.add(LoadAllEvents()));
  }

  void _navigateToDetail(BuildContext context, EventModel event) {
    Navigator.of(context).pushNamed(
      '/event-detail',
      arguments: {'eventId': event.id},
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
          'Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => _handleSignOut(context),
          ),
        ],
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventOperationSuccess) {
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
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

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

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<EventBloc>().add(LoadAllEvents()),
                child: CustomScrollView(
                  slivers: [
                    // Stats strip
                    SliverToBoxAdapter(
                      child: _buildStatsStrip(events, isTablet),
                    ),

                    // Section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 24 : 16,
                          20,
                          isTablet ? 24 : 16,
                          12,
                        ),
                        child: Text(
                          'All Events',
                          style: AppTheme.h3.copyWith(
                            fontSize: isTablet ? 22 : 18,
                          ),
                        ),
                      ),
                    ),

                    // Event list
                    events.isEmpty
                        ? SliverFillRemaining(
                      child: _buildEmptyState(isTablet),
                    )
                        : SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildEventCard(
                            context,
                            events[index],
                            isTablet,
                          ),
                          childCount: events.length,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                        child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(
          context,
          context.read<EventBloc>(),
        ),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: AppTheme.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Event',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatsStrip(List<EventModel> events, bool isTablet) {
    final draft = events.where((e) => e.isDraft).length;
    final active = events.where((e) => e.isActive).length;
    final completed = events.where((e) => e.isCompleted).length;

    return Container(
      color: const Color(0xFF7B1FA2),
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16,
        0,
        isTablet ? 24 : 16,
        20,
      ),
      child: Row(
        children: [
          _buildStatChip('Draft', draft, AppTheme.warning),
          const SizedBox(width: 12),
          _buildStatChip('Active', active, AppTheme.success),
          const SizedBox(width: 12),
          _buildStatChip('Completed', completed, AppTheme.info),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.15),
          borderRadius: AppTheme.radiusMedium,
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context,
      EventModel event,
      bool isTablet,
      ) {
    final statusColor = switch (event.status) {
      'draft' => AppTheme.warning,
      'active' => AppTheme.success,
      'completed' => AppTheme.info,
      _ => AppTheme.grey,
    };

    final statusBg = switch (event.status) {
      'draft' => AppTheme.warning.withOpacity(0.1),
      'active' => AppTheme.success.withOpacity(0.1),
      'completed' => AppTheme.info.withOpacity(0.1),
      _ => AppTheme.greyLight,
    };

    return GestureDetector(
      onTap: () => _navigateToDetail(context, event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
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
                    style: AppTheme.h3.copyWith(
                      fontSize: isTablet ? 18 : 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  child: Text(
                    event.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppTheme.textSecondary),
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
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy')
                      .format(event.eventDate.toDate()),
                  style: AppTheme.bodySmall,
                ),
                const Spacer(),
                _buildMiniStat(
                    Icons.people_outline, event.totalInvited, 'invited'),
                const SizedBox(width: 12),
                _buildMiniStat(
                    Icons.how_to_reg_outlined, event.totalCheckedIn, 'in'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, int count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          '$count $label',
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_rounded,
            size: isTablet ? 80 : 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No events yet',
            style: AppTheme.h3.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + New Event to get started',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}