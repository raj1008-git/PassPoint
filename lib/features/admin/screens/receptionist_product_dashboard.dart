import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/product_export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/product_repository.dart';
import '../../product/bloc/product_bloc.dart';
import '../../product/bloc/product_event.dart';
import '../../product/bloc/product_state.dart';
import '../../product/model/product_model.dart';
import '../../product/widgets/complete_product_dialog.dart';
import '../../product/widgets/product_details_dialog.dart';
import '../../product/widgets/product_list_tile.dart';

class ReceptionistProductDashboard extends StatefulWidget {
  final String receptionistName;

  const ReceptionistProductDashboard({Key? key, required this.receptionistName})
    : super(key: key);

  @override
  State<ReceptionistProductDashboard> createState() =>
      _ReceptionistProductDashboardState();
}

class _ReceptionistProductDashboardState
    extends State<ReceptionistProductDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _productRepository = ProductRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(
    List<ProductModel> products,
    String status,
  ) {
    var filtered = products;

    if (status != 'all') {
      filtered = filtered.where((p) => p.currentStatus == status).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final query = _searchQuery.toLowerCase();
        return p.registrationNumber.toLowerCase().contains(query) ||
            p.subject.toLowerCase().contains(query) ||
            p.senderOfficeName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _receiveProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Text('Receive Product'),
        content: Text(
          'Confirm receiving Registration #${product.registrationNumber}?\n\n'
          'This will route it to: ${product.targetDepartmentName} - ${product.targetPersonName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.checkedInGreenIcon,
            ),
            child: const Text('Receive'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ProductBloc>().add(
        ReceiveByReception(
          productId: product.id,
          receptionistName: widget.receptionistName,
        ),
      );
    }
  }

  Future<void> _completeProductIntervention(ProductModel product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => CompleteProductDialog(
        product: product,
        staffName: widget.receptionistName,
        department: 'Reception',
        isReceptionist: true,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product marked as completed (Receptionist Intervention)',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _exportProducts(List<ProductModel> products) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 16),
              Text('Exporting products...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final path = await ProductExportService.exportAllProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${products.length} products to:\n$path'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
          'Product Management',
          style: TextStyle(color: AppTheme.dark),
        ),
        actions: [
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              final products = (state is ProductLoaded)
                  ? state.products
                  : (state is ProductOperationInProgress)
                  ? state.products
                  : (state is ProductOperationSuccess)
                  ? state.products
                  : <ProductModel>[];

              return IconButton(
                icon: const Icon(Icons.download, color: AppTheme.info),
                tooltip: 'Export to CSV',
                onPressed: products.isEmpty
                    ? null
                    : () => _exportProducts(products),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by registration #, subject, or sender...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                    filled: true,
                    fillColor: AppTheme.greyLight.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Tabs with BADGE on "Submitted"
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryRed,
                unselectedLabelColor: AppTheme.grey,
                indicatorColor: AppTheme.primaryRed,
                isScrollable: true,
                tabs: [
                  // PHASE 3: Badge on "Submitted" tab
                  StreamBuilder<int>(
                    stream: _productRepository.getPendingCountForReceptionist(),
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data ?? 0;
                      return Tab(
                        child: Row(
                          children: [
                            const Text('Submitted'),
                            if (pendingCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$pendingCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const Tab(text: 'Received'),
                  const Tab(text: 'Forwarded'),
                  const Tab(text: 'Completed'),
                  const Tab(text: 'All'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTheme.bodyLarge),
                ],
              ),
            );
          }

          final products = (state is ProductLoaded)
              ? state.products
              : (state is ProductOperationInProgress)
              ? state.products
              : (state is ProductOperationSuccess)
              ? state.products
              : <ProductModel>[];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(_filterProducts(products, 'submitted')),
              _buildProductList(
                _filterProducts(products, 'received_by_reception'),
              ),
              _buildProductList(_filterProducts(products, 'forwarded')),
              _buildProductList(_filterProducts(products, 'completed')),
              _buildProductList(_filterProducts(products, 'all')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductListTile(
            product: product,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ProductDetailsDialog(product: product),
              );
            },
            actionButton: _buildActionButton(product),
          ),
        );
      },
    );
  }

  Widget? _buildActionButton(ProductModel product) {
    if (product.currentStatus == 'submitted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _receiveProduct(product),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Receive Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.checkedInGreenIcon,
            foregroundColor: AppTheme.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    if (product.currentStatus != 'completed') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _completeProductIntervention(product),
          icon: const Icon(Icons.admin_panel_settings, size: 18),
          label: const Text('Complete (Intervention)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.warning,
            side: const BorderSide(color: AppTheme.warning),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    return null;
  }
}
