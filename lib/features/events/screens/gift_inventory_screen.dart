// lib/features/events/screens/gift_inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_gift_model.dart';
import '../../../data/repositories/event_gift_repository.dart';
import '../bloc/gift_stock_bloc.dart';
import '../bloc/gift_stock_event.dart';
import '../bloc/gift_stock_state.dart';

class GiftInventoryScreen extends StatelessWidget {
  const GiftInventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final eventId = args['eventId'] as String;

    return BlocProvider(
      create: (_) =>
      GiftStockBloc(repository: EventGiftRepository())
        ..add(LoadGiftStock(eventId)),
      child: _GiftInventoryView(eventId: eventId),
    );
  }
}

class _GiftInventoryView extends StatefulWidget {
  final String eventId;
  const _GiftInventoryView({required this.eventId});

  @override
  State<_GiftInventoryView> createState() => _GiftInventoryViewState();
}

class _GiftInventoryViewState extends State<_GiftInventoryView> {
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _showAddSheet(BuildContext context) {
    _nameController.clear();
    _stockController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GiftStockBloc>(),
        child: _AddGiftSheet(
          eventId: widget.eventId,
          nameController: _nameController,
          stockController: _stockController,
          formKey: _formKey,
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, EventGiftModel gift) {
    _nameController.text = gift.name;
    _stockController.text = gift.totalStock.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GiftStockBloc>(),
        child: _EditGiftSheet(
          gift: gift,
          nameController: _nameController,
          stockController: _stockController,
          formKey: _formKey,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, EventGiftModel gift) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Text('Delete Gift'),
        content: Text(
          'Delete "${gift.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<GiftStockBloc>().add(DeleteGift(gift.id));
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
          'Gift Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<GiftStockBloc, GiftStockState>(
        listener: (context, state) {
          if (state is GiftStockOperationSuccess) {
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
          if (state is GiftStockLoading || state is GiftStockInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final gifts = switch (state) {
            GiftStockLoaded s => s.gifts,
            GiftStockOperationInProgress s => s.gifts,
            GiftStockOperationSuccess s => s.gifts,
            GiftStockError s => s.gifts,
            _ => <EventGiftModel>[],
          };

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              if (gifts.isEmpty) {
                return _buildEmpty(context, isTablet);
              }

              return ListView.separated(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                itemCount: gifts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildGiftTile(
                  context,
                  gifts[index],
                  isTablet,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: AppTheme.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Gift',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGiftTile(
      BuildContext context,
      EventGiftModel gift,
      bool isTablet,
      ) {
    final fraction = gift.stockFraction;
    final barColor = fraction > 0.5
        ? AppTheme.success
        : fraction > 0.2
        ? AppTheme.warning
        : AppTheme.error;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
        border:
        Border.all(color: AppTheme.greyLight.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  gift.name,
                  style: AppTheme.labelLarge
                      .copyWith(fontSize: isTablet ? 16 : 15),
                ),
              ),
              if (gift.assignedCount == 0) ...[
                IconButton(
                  onPressed: () => _showEditSheet(context, gift),
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(context, gift),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppTheme.error),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${gift.remainingStock} remaining',
                style: TextStyle(
                  color: barColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(' / '),
              Text(
                '${gift.totalStock} total',
                style: AppTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${gift.assignedCount} assigned',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppTheme.radiusSmall,
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppTheme.greyLight,
              color: barColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: isTablet ? 72 : 60,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No gifts added yet',
            style: AppTheme.h3.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add gift types and stock before inviting attendees',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Gift'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B1FA2),
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add gift bottom sheet
// ---------------------------------------------------------------------------

class _AddGiftSheet extends StatelessWidget {
  final String eventId;
  final TextEditingController nameController;
  final TextEditingController stockController;
  final GlobalKey<FormState> formKey;

  const _AddGiftSheet({
    required this.eventId,
    required this.nameController,
    required this.stockController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _GiftFormSheet(
      title: 'Add Gift',
      nameController: nameController,
      stockController: stockController,
      formKey: formKey,
      onSubmit: () {
        if (!formKey.currentState!.validate()) return;
        context.read<GiftStockBloc>().add(
          AddGift(
            eventId: eventId,
            name: nameController.text.trim(),
            totalStock: int.parse(stockController.text.trim()),
          ),
        );
        Navigator.pop(context);
      },
      submitLabel: 'Add Gift',
    );
  }
}

// ---------------------------------------------------------------------------
// Edit gift bottom sheet
// ---------------------------------------------------------------------------

class _EditGiftSheet extends StatelessWidget {
  final EventGiftModel gift;
  final TextEditingController nameController;
  final TextEditingController stockController;
  final GlobalKey<FormState> formKey;

  const _EditGiftSheet({
    required this.gift,
    required this.nameController,
    required this.stockController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _GiftFormSheet(
      title: 'Edit Gift',
      nameController: nameController,
      stockController: stockController,
      formKey: formKey,
      onSubmit: () {
        if (!formKey.currentState!.validate()) return;
        final newStock = int.tryParse(stockController.text.trim());
        context.read<GiftStockBloc>().add(
          UpdateGift(
            giftId: gift.id,
            name: nameController.text.trim() != gift.name
                ? nameController.text.trim()
                : null,
            totalStock: newStock != gift.totalStock ? newStock : null,
          ),
        );
        Navigator.pop(context);
      },
      submitLabel: 'Save Changes',
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form sheet
// ---------------------------------------------------------------------------

class _GiftFormSheet extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController stockController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final String submitLabel;

  const _GiftFormSheet({
    required this.title,
    required this.nameController,
    required this.stockController,
    required this.formKey,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: AppTheme.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Gift Name',
                  hintText: 'e.g. Pen, Cap, T-Shirt',
                  prefixIcon: const Icon(Icons.card_giftcard_outlined,
                      color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide:
                      BorderSide(color: AppTheme.greyLight)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide:
                      BorderSide(color: AppTheme.greyLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide: const BorderSide(
                          color: Color(0xFF7B1FA2), width: 2)),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Gift name required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Total Stock',
                  hintText: 'e.g. 1000',
                  prefixIcon: const Icon(Icons.inventory_2_outlined,
                      color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide:
                      BorderSide(color: AppTheme.greyLight)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide:
                      BorderSide(color: AppTheme.greyLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide: const BorderSide(
                          color: Color(0xFF7B1FA2), width: 2)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Stock quantity required';
                  }
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Text(
                  submitLabel,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}