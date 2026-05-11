// lib/features/events/screens/event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_invite_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/event_gift_repository.dart';
import '../../../data/repositories/invite_repository.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../bloc/invite_bloc.dart';
import '../bloc/invite_event.dart';
import '../bloc/invite_state.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final eventId = args['eventId'] as String;

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
          )..add(LoadInvites(eventId)),
        ),
      ],
      child: _EventDetailView(eventId: eventId),
    );
  }
}

class _EventDetailView extends StatelessWidget {
  final String eventId;
  const _EventDetailView({required this.eventId});

  void _navigateToAddInvitee(BuildContext context, EventModel event) {
    Navigator.of(context).pushNamed(
      '/add-invitee',
      arguments: {'eventId': eventId, 'event': event},
    );
  }

  void _navigateToGiftInventory(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/gift-inventory',
      arguments: {'eventId': eventId},
    );
  }

  void _navigateToScanner(BuildContext context) {
    Navigator.of(context).pushNamed('/event-scanner');
  }

  void _navigateToExport(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/event-export',
      arguments: {'eventId': eventId},
    );
  }

  void _handleDeleteInvite(
      BuildContext context,
      EventInviteModel invite,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Text('Remove Invitee'),
        content: Text(
          'Remove ${invite.name} from this event? '
              'Their gift allocation will be returned to inventory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<InviteBloc>().add(DeleteInvite(invite.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
        builder: (context, eventState) {
          final events = switch (eventState) {
            EventLoaded s => s.events,
            EventOperationInProgress s => s.events,
            EventOperationSuccess s => s.events,
            EventError s => s.events,
            _ => <EventModel>[],
          };

          final event = events.cast<EventModel?>().firstWhere(
                (e) => e?.id == eventId,
            orElse: () => null,
          );

          if (event == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              return NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  _buildAppBar(context, event, isTablet),
                ],
                body: BlocConsumer<InviteBloc, InviteState>(
                  listener: (context, state) {
                    if (state is InviteOperationSuccess) {
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

                    return CustomScrollView(
                      slivers: [
                        // Action buttons row
                        SliverToBoxAdapter(
                          child: _buildActionRow(
                              context, event, invites, isTablet),
                        ),

                        // Invitee list header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? 24 : 16,
                              16,
                              isTablet ? 24 : 16,
                              8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Invitees (${invites.length})',
                                  style: AppTheme.h3.copyWith(
                                    fontSize: isTablet ? 20 : 17,
                                  ),
                                ),
                                const Spacer(),
                                if (invites.any(
                                        (i) => !i.qrEmailSent))
                                  TextButton.icon(
                                    onPressed: () =>
                                        context.read<InviteBloc>().add(
                                          SendBulkQrEmails(eventId),
                                        ),
                                    icon: const Icon(
                                        Icons.send_outlined,
                                        size: 16),
                                    label: const Text('Send All QRs'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                      const Color(0xFF7B1FA2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Invitee list
                        invites.isEmpty
                            ? SliverFillRemaining(
                          child: _buildEmptyInvitees(isTablet),
                        )
                            : SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                  _buildInviteeRow(
                                    context,
                                    invites[index],
                                    isTablet,
                                  ),
                              childCount: invites.length,
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(
                            child: SizedBox(height: 80)),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          final events = switch (state) {
            EventLoaded s => s.events,
            _ => <EventModel>[],
          };
          final event = events.cast<EventModel?>().firstWhere(
                (e) => e?.id == eventId,
            orElse: () => null,
          );
          if (event == null || event.isCompleted) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _navigateToAddInvitee(context, event),
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: AppTheme.white,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text(
              'Add Invitee',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context,
      EventModel event,
      bool isTablet,
      ) {
    return SliverAppBar(
      expandedHeight: isTablet ? 200 : 170,
      pinned: true,
      backgroundColor: const Color(0xFF7B1FA2),
      foregroundColor: AppTheme.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 16,
            80,
            isTablet ? 24 : 16,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                event.name,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.venue,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today_outlined,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy')
                        .format(event.eventDate.toDate()),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (!event.isCompleted)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusMedium),
            onSelected: (value) {
              if (value == 'activate') {
                context
                    .read<EventBloc>()
                    .add(ActivateEvent(eventId));
              } else if (value == 'complete') {
                context
                    .read<EventBloc>()
                    .add(CompleteEvent(eventId));
              }
            },
            itemBuilder: (_) => [
              if (event.isDraft)
                const PopupMenuItem(
                  value: 'activate',
                  child: ListTile(
                    leading: Icon(Icons.play_arrow_rounded,
                        color: AppTheme.success),
                    title: Text('Activate Event'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (event.isActive)
                const PopupMenuItem(
                  value: 'complete',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline,
                        color: AppTheme.info),
                    title: Text('Mark Completed'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionRow(
      BuildContext context,
      EventModel event,
      List<EventInviteModel> invites,
      bool isTablet,
      ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Row(
        children: [
          _buildStatCard(
              'Invited', event.totalInvited, AppTheme.totalPurpleIcon),
          const SizedBox(width: 8),
          _buildStatCard(
              'Checked In', event.totalCheckedIn, AppTheme.success),
          const SizedBox(width: 8),
          _buildStatCard('Gifts Out',
              event.totalGiftsDistributed, AppTheme.info),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.card_giftcard_outlined,
            label: 'Gifts',
            onTap: () => _navigateToGiftInventory(context),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.download_outlined,
            label: 'Export',
            onTap: () => _navigateToExport(context),
          ),
          if (event.isActive) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan',
              onTap: () => _navigateToScanner(context),
              highlighted: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final color =
    highlighted ? const Color(0xFF7B1FA2) : AppTheme.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: highlighted
              ? const Color(0xFF7B1FA2).withOpacity(0.1)
              : AppTheme.greyLight,
          borderRadius: AppTheme.radiusMedium,
          border: highlighted
              ? Border.all(
              color: const Color(0xFF7B1FA2).withOpacity(0.3))
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteeRow(
      BuildContext context,
      EventInviteModel invite,
      bool isTablet,
      ) {
    final statusColor = switch (invite.attendanceStatus) {
      'pending' => AppTheme.pendingOrangeIcon,
      'checked_in' => AppTheme.checkedInGreenIcon,
      'checked_out' => AppTheme.checkedOutBlueIcon,
      _ => AppTheme.grey,
    };

    final statusLabel = switch (invite.attendanceStatus) {
      'pending' => 'Pending',
      'checked_in' => 'Checked In',
      'checked_out' => 'Checked Out',
      _ => invite.attendanceStatus,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.greyLight.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 22 : 18,
            backgroundColor:
            const Color(0xFF7B1FA2).withOpacity(0.12),
            child: Text(
              invite.name.isNotEmpty
                  ? invite.name[0].toUpperCase()
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
                Text(
                  invite.name,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 15 : 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  invite.isPmlilStaff && invite.branchName != null
                      ? invite.branchName!
                      : invite.phone,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    invite.qrEmailSent
                        ? Icons.mark_email_read_outlined
                        : Icons.email_outlined,
                    size: 14,
                    color: invite.qrEmailSent
                        ? AppTheme.success
                        : AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${invite.assignedGifts.length} gift(s)',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          if (!invite.isCheckedIn && !invite.isCheckedOut) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _handleDeleteInvite(context, invite),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.error,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyInvitees(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_disabled_outlined,
            size: isTablet ? 64 : 52,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No invitees yet',
            style: AppTheme.h3.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Add invitees using the button below',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}