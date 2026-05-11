// lib/features/events/bloc/invite_event.dart

import 'package:equatable/equatable.dart';

import '../../../data/models/event_gift_model.dart';
import '../../../data/models/event_invite_model.dart';

abstract class InviteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load and subscribe to all invites for a given event
class LoadInvites extends InviteEvent {
  final String eventId;

  LoadInvites(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// Create a new invite
class CreateInvite extends InviteEvent {
  final String eventId;
  final String eventName;
  final DateTime eventDate;
  final String eventVenue;
  final String phone;
  final String name;
  final String email;
  final bool isPmlilStaff;
  final String? branchName;
  final String? departmentName;
  final List<EventGiftModel> selectedGifts;

  CreateInvite({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventVenue,
    required this.phone,
    required this.name,
    required this.email,
    required this.isPmlilStaff,
    this.branchName,
    this.departmentName,
    required this.selectedGifts,
  });

  @override
  List<Object?> get props => [
    eventId,
    phone,
    name,
    email,
    isPmlilStaff,
    selectedGifts,
  ];
}

// Delete an invite (releases gift stock)
class DeleteInvite extends InviteEvent {
  final String inviteId;

  DeleteInvite(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

// Send bulk QR emails for all pending invites in event
class SendBulkQrEmails extends InviteEvent {
  final String eventId;

  SendBulkQrEmails(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// Internal — fired by stream listener
class InvitesUpdated extends InviteEvent {
  final List<EventInviteModel> invites;

  InvitesUpdated(this.invites);

  @override
  List<Object?> get props => [invites];
}